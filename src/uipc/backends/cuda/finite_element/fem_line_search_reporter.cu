#include <finite_element/fem_line_search_reporter.h>
#include <finite_element/finite_element_constitution.h>
#include <muda/cub/device/device_reduce.h>
#include <kernel_cout.h>
#include <muda/ext/eigen/log_proxy.h>

namespace uipc::backend::cuda
{
REGISTER_SIM_SYSTEM(FEMLineSearchReporter);

void FEMLineSearchReporter::do_build(LineSearchReporter::BuildInfo& info)
{
    m_impl.finite_element_method = &require<FiniteElementMethod>();
}

void FEMLineSearchReporter::do_record_start_point(LineSearcher::RecordInfo& info)
{
    m_impl.record_start_point(info);
}

void FEMLineSearchReporter::do_step_forward(LineSearcher::StepInfo& info)
{
    m_impl.step_forward(info);
}

void FEMLineSearchReporter::do_compute_energy(LineSearcher::EnergyInfo& info)
{
    m_impl.compute_energy(info);
}

void FEMLineSearchReporter::Impl::record_start_point(LineSearcher::RecordInfo& info)
{
    using namespace muda;

    fem().x_temps = fem().xs;
}

void FEMLineSearchReporter::Impl::step_forward(LineSearcher::StepInfo& info)
{
    using namespace muda;
    ParallelFor(256)
        .kernel_name(__FUNCTION__)
        .apply(fem().xs.size(),
               [is_fixed = fem().is_fixed.cviewer().name("is_fixed"),
                x_temps  = fem().x_temps.cviewer().name("x_temps"),
                xs       = fem().xs.viewer().name("xs"),
                dxs      = fem().dxs.cviewer().name("dxs"),
                alpha    = info.alpha] __device__(int i) mutable
               {
                   if(is_fixed(i))
                       return;
                   xs(i) = x_temps(i) + alpha * dxs(i);
               });
}

void FEMLineSearchReporter::Impl::compute_energy(LineSearcher::EnergyInfo& info)
{
    using namespace muda;

    // Compute kinetic energy
    ParallelFor()
        .kernel_name(__FUNCTION__)
        .apply(fem().xs.size(),
               [is_fixed = fem().is_fixed.cviewer().name("is_fixed"),
                xs       = fem().xs.cviewer().name("xs"),
                x_tildes = fem().x_tildes.viewer().name("x_tildes"),
                masses   = fem().masses.cviewer().name("masses"),
                Ks       = fem().vertex_kinetic_energies.viewer().name(
                    "kinetic_energy")] __device__(int i) mutable
               {
                   auto& K = Ks(i);
                   if(is_fixed(i))
                   {
                       K = 0.0;
                   }
                   else
                   {
                       const Vector3& x       = xs(i);
                       const Vector3& x_tilde = x_tildes(i);
                       Float          M       = masses(i);
                       Vector3        dx      = x - x_tilde;
                       K                      = 0.5 * M * dx.dot(dx);
                       // K                      = 0;
                   }
               });

    // Sum up kinetic energy
    DeviceReduce().Sum(fem().vertex_kinetic_energies.data(),
                       fem().kinetic_energy.data(),
                       fem().vertex_kinetic_energies.size());

    // Copy back to host
    Float K = fem().kinetic_energy;

    // Compute shape energy
    auto async_fill = []<typename T>(muda::DeviceBuffer<T>& buf, const T& value)
    { muda::BufferLaunch().fill<T>(buf.view(), value); };

    // Distribute the computation of shape energy to each constitution
    for(auto&& [i, cst] : enumerate(fem().constitutions.view()))
    {
        FiniteElementMethod::ComputeEnergyInfo this_info{
            &finite_element_method->m_impl, i, info.dt()};
        cst->compute_energy(this_info);
    }

    DeviceReduce().Sum(fem().codim_1d_elastic_energies.data(),
                       fem().codim_1d_elastic_energy.data(),
                       fem().codim_1d_elastic_energies.size());

    DeviceReduce().Sum(fem().codim_2d_elastic_energies.data(),
                       fem().codim_2d_elastic_energy.data(),
                       fem().codim_2d_elastic_energies.size());

    DeviceReduce().Sum(fem().fem_3d_elastic_energies.data(),
                       fem().fem_3d_elastic_energy.data(),
                       fem().fem_3d_elastic_energies.size());

    DeviceReduce().Sum(fem().extra_energies.data(),
                       fem().extra_energy.data(),
                       fem().extra_energies.size());


    Float E1      = fem().codim_1d_elastic_energy;
    Float E2      = fem().codim_2d_elastic_energy;
    Float E3      = fem().fem_3d_elastic_energy;
    Float extra_E = fem().extra_energy;

    //spdlog::info(
    //    "FEM K: {}, Codim1D-E: {}, Codim2D-E: {}, FEM3D-E: {}, FEM-Extra-E{}", K, E1, E2, E3, extra_E);

    info.energy(K + E1 + E2 + E3 + extra_E);
}
}  // namespace uipc::backend::cuda
