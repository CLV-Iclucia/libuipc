#include <uipc/world/apply_contact_element.h>

namespace uipc::world
{
void apply(const ContactElement& c, geometry::SimplicialComplex& sc)
{
    auto ces = sc.meta().find<IndexT>("contact_element_id");
    if(!ces)
    {
        ces = sc.meta().create<IndexT>("contact_element_id", c.id());
    }
    else
    {
        auto view    = geometry::view(*ces);
        view.front() = c.id();
    }
}
}  // namespace uipc::world