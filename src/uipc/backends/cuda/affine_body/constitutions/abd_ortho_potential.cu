#include <affine_body/constitutions/abd_ortho_potential.h>
#include <uipc/common/enumerate.h>
#include <affine_body/abd_energy.h>
#include <muda/cub/device/device_reduce.h>
#include <muda/ext/eigen/evd.h>
namespace uipc::backend::cuda
{
template <>
class SimSystemCreator<ABDOrthoPotential>
{
  public:
    static U<ISimSystem> create(SimEngine& engine)
    {
        auto scene = engine.world().scene();
        // Check if we have the AffineBodyDynamics Type
        auto& types = scene.constitution_tabular().types();
        if(types.find(world::ConstitutionTypes::AffineBody) == types.end())
            return nullptr;

        // Check if we have the ABDOrthoPotential constitution
        auto uids = scene.constitution_tabular().uids();
        if(!std::binary_search(uids.begin(), uids.end(), ABDOrthoPotential::ConstitutionUID))
            return nullptr;

        return static_pointer_cast<ISimSystem>(make_unique<AffineBodyDynamics>(engine));
    }
};

REGISTER_SIM_SYSTEM(ABDOrthoPotential);

void ABDOrthoPotential::do_build()
{
    m_impl.affine_body_geometry = find<AffineBodyDynamics>();

    // ConstitutionRegister the action to filter the affine body geometry
    m_impl.affine_body_geometry->on_update(
        ConstitutionUID,  // By libuipc specification
        [this](const AffineBodyDynamics::FilteredInfo& info)
        { m_impl.on_filter(info, world()); },
        [this](const AffineBodyDynamics::ComputeEnergyInfo& info)
        { m_impl.on_compute_energy(info); },
        [this](const AffineBodyDynamics::ComputeGradientHessianInfo& info) {

        });
}

void ABDOrthoPotential::Impl::on_filter(const AffineBodyDynamics::FilteredInfo& info,
                                        WorldVisitor& world)
{
    auto src = info.body_infos();
    h_body_infos.resize(src.size());
    std::ranges::copy(src, h_body_infos.begin());

    // find out constitution coefficients
    h_kappas.resize(src.size());
    auto geo_slots = world.scene().geometries();

    info.for_each_body(
        geo_slots,
        [](geometry::SimplicialComplex& sc)
        { return sc.instances().find<Float>("kappa")->view(); },
        [&](SizeT I, Float kappa) { h_kappas[I] = kappa; });

    _build_on_device();
}

void ABDOrthoPotential::Impl::on_compute_energy(const AffineBodyDynamics::ComputeEnergyInfo& info)
{
    using namespace muda;

    auto body_count = info.qs().size();
    info.qs();
    info.shape_energy();


    ParallelFor()
        .kernel_name(__FUNCTION__)
        .apply(body_count,
               [shape_energies = body_energies.viewer().name("body_energies"),
                qs             = info.qs().cviewer().name("qs"),
                kappas         = kappas.cviewer().name("kappas"),
                volumes        = info.volumes().cviewer().name("volumes"),
                dt             = info.dt()] __device__(int i) mutable
               {
                   auto& V      = shape_energies(i);
                   auto& q      = qs(i);
                   auto& volume = volumes(i);
                   auto  kappa  = kappas(i);

                   V = kappa * volume * dt * dt * shape_energy(q);
               });

    // Sum up the body energies
    DeviceReduce().Sum(body_energies.data(), info.shape_energy().data(), body_count);
}

// file local function, make the matrix positive definite
__device__ __host__ void make_pd(Matrix9x9& mat)
{
    Vector9   eigen_values;
    Matrix9x9 eigen_vectors;
    muda::eigen::evd(mat, eigen_values, eigen_vectors);
    for(int i = 0; i < 9; ++i)
    {
        if(eigen_values(i) < 0)
        {
            eigen_values(i) = 0;
        }
    }
    mat = eigen_vectors * eigen_values.asDiagonal() * eigen_vectors.transpose();
}

void ABDOrthoPotential::Impl::on_compute_gradient_hessian(const AffineBodyDynamics::ComputeGradientHessianInfo& info)
{
    using namespace muda;
    auto N = info.qs().size();

    ParallelFor(256)
        .kernel_name(__FUNCTION__)
        .apply(N,
               [qs      = info.qs().cviewer().name("qs"),
                volumes = info.volumes().cviewer().name("volumes"),
                gradients = info.shape_gradient().viewer().name("shape_gradients"),
                body_hessian = info.shape_hessian().viewer().name("shape_hessian"),
                kappas = kappas.cviewer().name("kappas"),
                dt     = info.dt()] __device__(int i) mutable
               {
                   Matrix12x12 H = Matrix12x12::Zero();
                   Vector12    G = Vector12::Zero();

                   const auto& q              = qs(i);
                   Float       kappa          = kappas(i);
                   const auto& volume         = volumes(i);
                   auto        kvt2           = kappa * volume * dt * dt;
                   Vector9     shape_gradient = kvt2 * shape_energy_gradient(q);

                   Matrix9x9 shape_H = kvt2 * shape_energy_hessian(q);

                   // make H positive definite
                   make_pd(shape_H);
                   H.block<9, 9>(3, 3) += shape_H;
                   G.segment<9>(3) += shape_gradient;

                   gradients(i)    = G;
                   body_hessian(i) = H;
               });
}

void ABDOrthoPotential::Impl::_build_on_device()
{
    auto async_copy = []<typename T>(span<T> src, muda::DeviceBuffer<T>& dst)
    {
        muda::BufferLaunch().resize<T>(dst, src.size());
        muda::BufferLaunch().copy<T>(dst.view(), src.data());
    };

    auto async_resize = []<typename T>(muda::DeviceBuffer<T>& dst, SizeT size)
    { muda::BufferLaunch().resize<T>(dst, size); };

    async_copy(span{h_kappas}, kappas);
    async_resize(body_energies, kappas.size());
}
}  // namespace uipc::backend::cuda
