#include <app/test_common.h>
#include <app/asset_dir.h>
#include <uipc/geometry.h>
#include <uipc/geometry/utils/label_surface.h>

using namespace uipc;
using namespace uipc::geometry;

TEST_CASE("label_surface", "[surface]")
{
    SimplicialComplexIO io;
    auto mesh = io.read_msh(fmt::format("{}cube.msh", AssetDir::tetmesh_path()));

    auto labeled_mesh = label_surface(mesh);
    spdlog::info("labeled_mesh: {}", labeled_mesh);
    auto is_surf_view = labeled_mesh.vertices().find<IndexT>(builtin::is_surf)->view();
    // for a cube, all vertices are on the surface
    REQUIRE(std::ranges::all_of(is_surf_view, [](auto s) -> bool { return s; }));
}
