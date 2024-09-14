#include <pyuipc/constitution/finite_element_extra_constitution.h>
#include <uipc/constitution/finite_element_extra_constitution.h>

namespace pyuipc::constitution
{
using namespace uipc::constitution;
PyFiniteElementExtraConstitution::PyFiniteElementExtraConstitution(py::module& m)
{
    auto class_FiniteElementExtraConstitution =
        py::class_<FiniteElementExtraConstitution, IConstitution>(m, "FiniteElementExtraConstitution");
}
}  // namespace pyuipc::constitution
