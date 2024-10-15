#pragma once
#include <finite_element/finite_element_constitution.h>

namespace uipc::backend::cuda
{
class FEM3DConstitution : public FiniteElementConstitution
{
  public:
    using FiniteElementConstitution::FiniteElementConstitution;

    class BuildInfo
    {
      public:
    };

    class BaseInfo
    {
      public:
        BaseInfo(FiniteElementMethod::Impl* impl, SizeT index_in_dim, Float dt)
            : m_fem(impl)
            , m_index_in_dim(index_in_dim)
            , m_dt(dt)
        {
        }

        muda::CBufferView<Vector3>   xs() const noexcept;
        muda::CBufferView<Vector3>   x_bars() const noexcept;
        muda::CBufferView<Matrix3x3> Dm_invs() const noexcept;
        muda::CBufferView<Float>     rest_volumes() const noexcept;
        muda::CBufferView<Vector4i>  indices() const noexcept;
        const FiniteElementMethod::ConstitutionInfo& constitution_info() const noexcept;
        auto dt() const noexcept { return m_dt; }

      protected:
        SizeT                      m_index_in_dim = ~0ull;
        FiniteElementMethod::Impl* m_fem          = nullptr;
        Float                      m_dt           = 0.0;
    };

    class ComputeEnergyInfo : public BaseInfo
    {
      public:
        ComputeEnergyInfo(FiniteElementMethod::Impl* impl,
                          SizeT                      index_in_dim,
                          Float                      dt,
                          muda::BufferView<Float>    energies)
            : BaseInfo(impl, index_in_dim, dt)
            , m_energies(energies)
        {
        }

        auto energies() const noexcept { return m_energies; }

      private:
        muda::BufferView<Float> m_energies;
    };

    class ComputeGradientHessianInfo : public BaseInfo
    {
      public:
        ComputeGradientHessianInfo(FiniteElementMethod::Impl* impl,
                                   SizeT                      index_in_dim,
                                   Float                      dt,
                                   muda::DoubletVectorView<Float, 3> gradients,
                                   muda::TripletMatrixView<Float, 3> hessians)
            : BaseInfo(impl, index_in_dim, dt)
            , m_gradients(gradients)
            , m_hessians(hessians)
        {
        }

        auto gradients() const noexcept { return m_gradients; }
        auto hessians() const noexcept { return m_hessians; }

      private:
        muda::DoubletVectorView<Float, 3> m_gradients;
        muda::TripletMatrixView<Float, 3> m_hessians;
    };

  protected:
    virtual void do_init(FiniteElementMethod::FEM3DFilteredInfo& info) = 0;
    virtual void do_build(BuildInfo& info)                             = 0;
    virtual void do_report_extent(ReportExtentInfo& info) override;
    virtual void do_compute_energy(ComputeEnergyInfo& info) = 0;
    virtual void do_compute_gradient_hessian(ComputeGradientHessianInfo& info) = 0;
    const FiniteElementMethod::ConstitutionInfo& constitution_info() const noexcept;

  private:
    friend class FiniteElementMethod;
    void init(FiniteElementMethod::FEM3DFilteredInfo& info);
    virtual void do_build(FiniteElementConstitution::BuildInfo& info) override final;
    virtual void do_compute_energy(FiniteElementEnergyProducer::ComputeEnergyInfo& info) override final;
    virtual void do_compute_gradient_hessian(
        FiniteElementEnergyProducer::ComputeGradientHessianInfo& info) override final;
    virtual IndexT   get_dimension() const noexcept override final;
    virtual Vector2i get_vertex_offset_count() const noexcept override final;
};
}  // namespace uipc::backend::cuda
