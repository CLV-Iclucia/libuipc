#include <pyuipc/constitution/constitution.h>
#include <uipc/constitution/constitution.h>

namespace pyuipc::constitution
{
using namespace uipc::constitution;
PyConstitution::PyConstitution(py::module& m)
{

    py::enum_<ConstitutionType>(m, "ConstitutionType")
        .value("AffineBody", ConstitutionType::AffineBody)
        .value("FiniteElement", ConstitutionType::FiniteElement)
        .value("Constraint", ConstitutionType::Constraint);

    auto class_IConstitution = py::class_<IConstitution>(m, "IConstitution");

    class_IConstitution.def("uid", &IConstitution::uid);
    class_IConstitution.def("name", &IConstitution::name);
    class_IConstitution.def("type", &IConstitution::type);
}
}  // namespace pyuipc::constitution
