#include <finite_element/codim_1d_constitution.h>

namespace uipc::backend::cuda
{
void Codim1DConstitution::retrieve(FiniteElementMethod::Codim1DFilteredInfo& info)
{
    do_retrieve(info);
}

void Codim1DConstitution::do_build(FiniteElementConstitution::BuildInfo& info)
{
    Codim1DConstitution::BuildInfo this_info;
    do_build(this_info);
}

void Codim1DConstitution::do_compute_energy(FiniteElementMethod::ComputeEnergyInfo& info)
{
    Codim1DConstitution::ComputeEnergyInfo this_info{&fem(), m_index_in_dim, info.dt()};
    do_compute_energy(this_info);
}

void Codim1DConstitution::do_compute_gradient_hessian(FiniteElementMethod::ComputeGradientHessianInfo& info)
{
    ComputeGradientHessianInfo this_info{&fem(), m_index_in_dim, info.dt()};
    do_compute_gradient_hessian(this_info);
}

IndexT Codim1DConstitution::get_dimension() const
{
    return 1;
}

muda::CBufferView<Vector3> Codim1DConstitution::BaseInfo::xs() const noexcept
{
    return m_fem->xs.view();  // must return full buffer, because the indices index into the full buffer
}

muda::CBufferView<Vector3> Codim1DConstitution::BaseInfo::x_bars() const noexcept
{
    return m_fem->x_bars.view();  // must return full buffer, because the indices index into the full buffer
}

muda::CBufferView<Float> Codim1DConstitution::BaseInfo::rest_lengths() const noexcept
{
    auto& info = constitution_info();
    return m_fem->rest_lengths.view(info.primitive_offset, info.primitive_count);
}

muda::CBufferView<Float> Codim1DConstitution::BaseInfo::thicknesses() const noexcept
{
    return m_fem->thicknesses.view();
}

muda::CBufferView<Vector2i> Codim1DConstitution::BaseInfo::indices() const noexcept
{
    auto& info = constitution_info();
    return m_fem->codim_1ds.view(info.primitive_offset, info.primitive_count);
}

const FiniteElementMethod::ConstitutionInfo& Codim1DConstitution::BaseInfo::constitution_info() const noexcept
{
    return m_fem->codim_1d_constitution_infos[m_index_in_dim];
}

Float Codim1DConstitution::BaseInfo::dt() const noexcept
{
    return m_dt;
}

muda::BufferView<Float> Codim1DConstitution::ComputeEnergyInfo::element_energies() const noexcept
{
    auto& info = constitution_info();
    return m_fem->codim_1d_elastic_energies.view(info.primitive_offset, info.primitive_count);
}

muda::BufferView<Vector6> Codim1DConstitution::ComputeGradientHessianInfo::gradient() const noexcept
{
    auto& info = constitution_info();
    return m_fem->G6s.view(info.primitive_offset, info.primitive_count);
}
muda::BufferView<Matrix6x6> Codim1DConstitution::ComputeGradientHessianInfo::hessian() const noexcept
{
    auto& info = constitution_info();
    return m_fem->H6x6s.view(info.primitive_offset, info.primitive_count);
}
}  // namespace uipc::backend::cuda
