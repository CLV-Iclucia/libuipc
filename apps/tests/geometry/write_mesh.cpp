#include <catch.hpp>
#include <app/asset_dir.h>
#include <uipc/geometry/io.h>
#include <uipc/common/format.h>

using namespace uipc;
using namespace uipc::geometry;


TEST_CASE("wirte_obj", "[io]")
{
    SimplicialComplexIO io;
    auto mesh = io.read_obj(fmt::format("{}cube.obj", AssetDir::trimesh_path()));
    io.write_obj(fmt::format("{}cube_out.obj", AssetDir::output_path()), mesh);
}
