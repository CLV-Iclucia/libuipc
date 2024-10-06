#include <pyuipc/core/world.h>
#include <uipc/core/world.h>
#include <uipc/core/engine.h>

namespace pyuipc::core
{
using namespace uipc::core;

PyWorld::PyWorld(py::module& m)
{
    auto class_World = py::class_<World>(m, "World");

    class_World.def(py::init<Engine&>())
        .def("init", &World::init, py::arg("scene"))
        .def("advance", &World::advance)
        .def("sync", &World::sync)
        .def("retrieve", &World::retrieve)
        .def("dump", &World::dump)
        .def("recover", &World::recover)
        .def("frame", &World::frame);
}

}  // namespace pyuipc::core