#include <uipc/constitution/affine_body_constitution.h>
#include <uipc/builtin/constitution_uid_auto_register.h>
#include <uipc/builtin/attribute_name.h>
#include <uipc/builtin/constitution_type.h>
#include <uipc/geometry/utils/compute_vertex_mass.h>

namespace uipc::constitution
{
REGISTER_CONSTITUTION_UIDS()
{
    using namespace uipc::builtin;
    list<UIDInfo> uids;
    // create 8 AffineBody constitution uids
    auto affine_body = string{builtin::AffineBody};
    uids.push_back(UIDInfo{.uid = 1, .name = "OrthoPotential", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 2, .name = "ARAP", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 3, .name = "AffineBody", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 4, .name = "AffineBody", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 5, .name = "AffineBody", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 6, .name = "AffineBody", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 7, .name = "AffineBody", .type = affine_body});
    uids.push_back(UIDInfo{.uid = 8, .name = "AffineBody", .type = affine_body});
    return uids;
}

void AffineBodyMaterial::apply_to(geometry::SimplicialComplex& sc) const
{
    m_constitution.apply_to(sc, m_kappa, m_mass_density);
}

AffineBodyMaterial::AffineBodyMaterial(const AffineBodyConstitution& ab,
                                       Float                         kappa,
                                       Float mass_density) noexcept
    : m_constitution(ab)
    , m_kappa(kappa)
    , m_mass_density(mass_density)
{
}

AffineBodyConstitution::AffineBodyConstitution(const Json& config) noexcept
    : m_config(config)
{
}

AffineBodyMaterial AffineBodyConstitution::create_material(Float kappa) const noexcept
{
    return AffineBodyMaterial{*this, kappa};
}

U64 AffineBodyConstitution::get_uid() const noexcept
{
    if(m_config["name"] == "OrthoPotential")
        return 1;
    else if(m_config["name"] == "ARAP")
        return 2;

    return 1;
}

void AffineBodyConstitution::apply_to(geometry::SimplicialComplex& sc, Float kappa, Float mass_density) const
{
    auto P = sc.meta().find<U64>(builtin::constitution_uid);

    if(!P)
        P = sc.meta().create<U64>(builtin::constitution_uid, uid());
    else
        geometry::view(*P).front() = uid();

    auto is_fixed = sc.instances().find<IndexT>(builtin::is_fixed);
    if(!is_fixed)
        is_fixed = sc.instances().create<IndexT>(builtin::is_fixed, 0);
    auto is_kinematic = sc.instances().find<IndexT>(builtin::is_kinematic);
    if(!is_kinematic)
        is_kinematic = sc.instances().create<IndexT>(builtin::is_kinematic, 0);

    auto kappa_attr = sc.instances().find<Float>("kappa");
    if(!kappa_attr)
        kappa_attr = sc.instances().create<Float>("kappa", kappa);
    auto kappa_view = geometry::view(*kappa_attr);
    std::ranges::fill(kappa_view, kappa);

    geometry::compute_vertex_mass(sc, mass_density);
}

Json AffineBodyConstitution::default_config() noexcept
{
    Json j    = Json::object();
    j["name"] = "OrthoPotential";
    return j;
}
}  // namespace uipc::constitution