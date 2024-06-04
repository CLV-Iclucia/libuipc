#pragma once
#include <uipc/common/span.h>
#include <uipc/geometry/simplicial_complex.h>
#include <uipc/geometry/implicit_geometry.h>

namespace uipc::geometry
{
/**
 * @brief Create a simplicial complex from a tetrahedral mesh.
 * 
 * @param Vs The vertex positions of the tetrahedral mesh
 * @param Ts The tetrahedra of the tetrahedral mesh
 */
[[nodiscard]] SimplicialComplex tetmesh(span<const Vector3>  Vs,
                                        span<const Vector4i> Ts);
/**
 * @brief Create a simplicial complex from a triangle mesh.
 * 
 * @param Vs The vertex positions of the triangle mesh
 * @param Fs The triangles of the triangle mesh
 * @return SimplicialComplex 
 */
[[nodiscard]] SimplicialComplex trimesh(span<const Vector3>  Vs,
                                        span<const Vector3i> Fs);
/**
 * @brief Create a simplicial complex from a line mesh.
 * 
 * @param Vs The vertex positions of the line mesh
 * @param Es The edges of the line mesh
 * @return SimplicialComplex 
 */
[[nodiscard]] SimplicialComplex linemesh(span<const Vector3>  Vs,
                                         span<const Vector2i> Es);
/**
 * @brief Create a simplicial complex from a point cloud.
 * 
 * @param Vs The vertex positions of the point cloud
 * @return SimplicialComplex 
 */
[[nodiscard]] SimplicialComplex pointcloud(span<const Vector3> Vs);

/**
 * @brief Create a gound plane.
 * 
 * @pram height The height of the ground plane
 */
[[nodiscard]] ImplicitGeometry ground(Float height = 0.0);

}  // namespace uipc::geometries