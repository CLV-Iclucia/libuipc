import numpy
from typing import Iterator, overload

class AttributeCollection:
    def __init__(self, *args, **kwargs) -> None: ...
    def attribute_count(self) -> int: ...
    def clear(self) -> None: ...
    @overload
    def create(self, arg0: str, arg1: numpy.ndarray[numpy.float64]) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: numpy.ndarray[numpy.int32]) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: numpy.ndarray[numpy.uint64]) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: numpy.ndarray[numpy.int64]) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: str) -> AttributeSlotString: ...
    @overload
    def create(self, arg0: str, arg1: int) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: int) -> IAttributeSlot: ...
    @overload
    def create(self, arg0: str, arg1: float) -> IAttributeSlot: ...
    def destroy(self, arg0: str) -> None: ...
    def find(self, arg0: str) -> IAttributeSlot: ...
    def reorder(self, arg0: numpy.ndarray[numpy.uint64]) -> None: ...
    def reserve(self, arg0: int) -> None: ...
    def resize(self, arg0: int) -> None: ...
    def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
    def size(self) -> int: ...

class AttributeSlotFloat(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotI32(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.int32]: ...

class AttributeSlotI64(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.int64]: ...

class AttributeSlotMatrix12x12(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotMatrix2x2(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotMatrix3x3(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotMatrix4x4(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotMatrix6x6(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotMatrix9x9(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotString(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> CStringSpan: ...

class AttributeSlotU32(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.uint32]: ...

class AttributeSlotU64(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.uint64]: ...

class AttributeSlotVector12(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotVector2(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotVector2i(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.int32]: ...

class AttributeSlotVector3(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotVector3i(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.int32]: ...

class AttributeSlotVector4(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotVector4i(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.int32]: ...

class AttributeSlotVector6(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class AttributeSlotVector9(IAttributeSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class CStringSpan:
    def __init__(self) -> None: ...
    def __getitem__(self, arg0: int) -> str: ...
    def __iter__(self) -> Iterator[str]: ...
    def __len__(self) -> int: ...

class EdgeSlot(ISimplexSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> None: ...

class Geometry:
    class InstanceAttributes:
        def __init__(self, *args, **kwargs) -> None: ...
        def clear(self) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        def find(self, arg0: str) -> IAttributeSlot: ...
        def reserve(self, arg0: int) -> None: ...
        def resize(self, arg0: int) -> None: ...
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def size(self) -> int: ...
        def to_json(self) -> json: ...

    class MetaAttributes:
        def __init__(self, *args, **kwargs) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        def find(self, arg0: str) -> IAttributeSlot: ...
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def to_json(self) -> json: ...
    def __init__(self, *args, **kwargs) -> None: ...
    def instances(self) -> Geometry.InstanceAttributes: ...
    def meta(self) -> Geometry.MetaAttributes: ...
    def to_json(self) -> json: ...
    def transforms(self) -> AttributeSlotMatrix4x4: ...
    def type(self) -> str: ...

class GeometrySlot:
    def __init__(self, *args, **kwargs) -> None: ...
    def geometry(self) -> Geometry: ...
    def id(self) -> int: ...

class IAttributeSlot:
    def __init__(self, *args, **kwargs) -> None: ...
    def allow_destroy(self) -> bool: ...
    def is_shared(self) -> bool: ...
    def name(self) -> str: ...
    def size(self) -> int: ...
    def type_name(self) -> str: ...
    def view(self) -> numpy.ndarray: ...

class ISimplexSlot:
    def __init__(self, *args, **kwargs) -> None: ...
    def is_shared(self) -> bool: ...
    def reorder(self, arg0: numpy.ndarray[numpy.uint64]) -> None: ...
    def size(self) -> int: ...

class ImplicitGeometry(Geometry):
    def __init__(self) -> None: ...

class ImplicitGeometrySlot(GeometrySlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def geometry(self) -> ImplicitGeometry: ...

class SimplicialComplex(Geometry):
    class EdgeAttributes:
        class Topo:
            def __init__(self, *args, **kwargs) -> None: ...
            def is_shared(self) -> bool: ...
            def share(self, arg0: SimplicialComplex.EdgeAttributes.Topo) -> None: ...
            def view(self) -> numpy.ndarray[numpy.int32]: ...
        def __init__(self, *args, **kwargs) -> None: ...
        def clear(self) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        def find(self, arg0: str) -> IAttributeSlot: ...
        def is_shared(self) -> bool: ...
        def reserve(self, arg0: int) -> None: ...
        def resize(self, arg0: int) -> None: ...
        @overload
        def share(self, arg0: SimplicialComplex.EdgeAttributes.Topo) -> None: ...
        @overload
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def size(self) -> int: ...
        def to_json(self) -> json: ...
        def topo(self) -> SimplicialComplex.EdgeAttributes.Topo: ...
        def view(self) -> numpy.ndarray[numpy.int32]: ...

    class TetrahedronAttributes:
        class Topo:
            def __init__(self, *args, **kwargs) -> None: ...
            def is_shared(self) -> bool: ...
            def share(self, arg0: SimplicialComplex.TetrahedronAttributes.Topo) -> None: ...
            def view(self) -> numpy.ndarray[numpy.int32]: ...
        def __init__(self, *args, **kwargs) -> None: ...
        def clear(self) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        def find(self, arg0: str) -> IAttributeSlot: ...
        def is_shared(self) -> bool: ...
        def reserve(self, arg0: int) -> None: ...
        def resize(self, arg0: int) -> None: ...
        @overload
        def share(self, arg0: SimplicialComplex.TetrahedronAttributes.Topo) -> None: ...
        @overload
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def size(self) -> int: ...
        def to_json(self) -> json: ...
        def topo(self) -> SimplicialComplex.TetrahedronAttributes.Topo: ...
        def view(self) -> numpy.ndarray[numpy.int32]: ...

    class TriangleAttributes:
        class Topo:
            def __init__(self, *args, **kwargs) -> None: ...
            def is_shared(self) -> bool: ...
            def share(self, arg0: SimplicialComplex.TriangleAttributes.Topo) -> None: ...
            def view(self) -> numpy.ndarray[numpy.int32]: ...
        def __init__(self, *args, **kwargs) -> None: ...
        def clear(self) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        def find(self, arg0: str) -> IAttributeSlot: ...
        def is_shared(self) -> bool: ...
        def reserve(self, arg0: int) -> None: ...
        def resize(self, arg0: int) -> None: ...
        @overload
        def share(self, arg0: SimplicialComplex.TriangleAttributes.Topo) -> None: ...
        @overload
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def size(self) -> int: ...
        def to_json(self) -> json: ...
        def topo(self) -> SimplicialComplex.TriangleAttributes.Topo: ...
        def view(self) -> numpy.ndarray[numpy.int32]: ...

    class VertexAttributes:
        class Topo:
            def __init__(self, *args, **kwargs) -> None: ...
            def is_shared(self) -> bool: ...
            def share(self, arg0: SimplicialComplex.VertexAttributes.Topo) -> None: ...
            def view(self) -> numpy.ndarray[numpy.int32]: ...
        def __init__(self, *args, **kwargs) -> None: ...
        def clear(self) -> None: ...
        def create(self, arg0: str, arg1: object) -> IAttributeSlot: ...
        def destroy(self, arg0: str) -> None: ...
        @overload
        def find(self, arg0: str) -> IAttributeSlot: ...
        @overload
        def find(self, arg0: str) -> IAttributeSlot: ...
        def is_shared(self) -> bool: ...
        def reserve(self, arg0: int) -> None: ...
        def resize(self, arg0: int) -> None: ...
        @overload
        def share(self, arg0: SimplicialComplex.VertexAttributes.Topo) -> None: ...
        @overload
        def share(self, arg0: str, arg1: IAttributeSlot) -> None: ...
        def size(self) -> int: ...
        def to_json(self) -> json: ...
        def topo(self) -> SimplicialComplex.VertexAttributes.Topo: ...
        def view(self) -> numpy.ndarray[numpy.int32]: ...
    def __init__(self) -> None: ...
    def edges(self) -> SimplicialComplex.EdgeAttributes: ...
    def positions(self) -> AttributeSlotVector3: ...
    def tetrahedra(self) -> SimplicialComplex.TetrahedronAttributes: ...
    def triangles(self) -> SimplicialComplex.TriangleAttributes: ...
    def vertices(self) -> SimplicialComplex.VertexAttributes: ...

class SimplicialComplexIO:
    @overload
    def __init__(self) -> None: ...
    @overload
    def __init__(self, arg0: numpy.ndarray[numpy.float64]) -> None: ...
    def read(self, arg0: str) -> SimplicialComplex: ...

class SimplicialComplexSlot(GeometrySlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def geometry(self) -> SimplicialComplex: ...

class SpreadSheetIO:
    def __init__(self, output_folder: str = ...) -> None: ...
    @overload
    def write_csv(self, geo_name: str, simplicial_complex: SimplicialComplex) -> None: ...
    @overload
    def write_csv(self, arg0: SimplicialComplex) -> None: ...
    @overload
    def write_json(self, geo_name: str, simplicial_complex: SimplicialComplex) -> None: ...
    @overload
    def write_json(self, arg0: SimplicialComplex) -> None: ...

class StringSpan:
    def __init__(self) -> None: ...
    def __getitem__(self, arg0: int) -> str: ...
    def __iter__(self) -> Iterator[str]: ...
    def __len__(self) -> int: ...
    def __setitem__(self, arg0: int, arg1: str) -> None: ...

class TetrahedronSlot(ISimplexSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> None: ...

class TriangleSlot(ISimplexSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> None: ...

class VertexSlot(ISimplexSlot):
    def __init__(self, *args, **kwargs) -> None: ...
    def view(self) -> None: ...

def flip_inward_triangles(arg0: SimplicialComplex) -> SimplicialComplex: ...
def ground(height: float = ..., N: numpy.ndarray[numpy.float64] = ...) -> ImplicitGeometry: ...
def label_surface(arg0: SimplicialComplex) -> None: ...
def label_triangle_orient(arg0: SimplicialComplex) -> AttributeSlotI32: ...
def linemesh(arg0: numpy.ndarray[numpy.float64], arg1: numpy.ndarray[numpy.int32]) -> SimplicialComplex: ...
def pointcloud(arg0: numpy.ndarray[numpy.float64]) -> SimplicialComplex: ...
def tetmesh(arg0: numpy.ndarray[numpy.float64], arg1: numpy.ndarray[numpy.int32]) -> SimplicialComplex: ...
def trimesh(arg0: numpy.ndarray[numpy.float64], arg1: numpy.ndarray[numpy.int32]) -> SimplicialComplex: ...
@overload
def view(arg0: AttributeSlotString) -> StringSpan: ...
@overload
def view(arg0: AttributeSlotFloat) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotI32) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: AttributeSlotI64) -> numpy.ndarray[numpy.int64]: ...
@overload
def view(arg0: AttributeSlotU32) -> numpy.ndarray[numpy.uint32]: ...
@overload
def view(arg0: AttributeSlotU64) -> numpy.ndarray[numpy.uint64]: ...
@overload
def view(arg0: AttributeSlotVector2) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector3) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector4) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector6) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector9) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector12) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotVector2i) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: AttributeSlotVector3i) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: AttributeSlotVector4i) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: AttributeSlotMatrix2x2) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotMatrix3x3) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotMatrix4x4) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotMatrix6x6) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotMatrix9x9) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: AttributeSlotMatrix12x12) -> numpy.ndarray[numpy.float64]: ...
@overload
def view(arg0: VertexSlot) -> None: ...
@overload
def view(arg0: EdgeSlot) -> None: ...
@overload
def view(arg0: TriangleSlot) -> None: ...
@overload
def view(arg0: TetrahedronSlot) -> None: ...
@overload
def view(arg0: SimplicialComplex.VertexAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.VertexAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.EdgeAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.EdgeAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.TriangleAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.TriangleAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.TetrahedronAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
@overload
def view(arg0: SimplicialComplex.TetrahedronAttributes.Topo) -> numpy.ndarray[numpy.int32]: ...
