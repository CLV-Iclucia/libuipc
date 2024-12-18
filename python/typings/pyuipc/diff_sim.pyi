import numpy
import scipy.sparse

class ParameterCollection:
    def __init__(self, *args, **kwargs) -> None: ...
    def broadcast(self) -> None: ...
    def resize(self, N: int, default_value: float = ...) -> None: ...
    def view(self) -> numpy.ndarray[numpy.float64]: ...

class SparseCOOView:
    def __init__(self, *args, **kwargs) -> None: ...
    def col_indices(self) -> numpy.ndarray[numpy.int32]: ...
    def row_indices(self) -> numpy.ndarray[numpy.int32]: ...
    def shape(self) -> numpy.ndarray[numpy.int32[2, 1]]: ...
    def to_dense(self) -> numpy.ndarray[numpy.float64[m, n]]: ...
    def to_sparse(self) -> scipy.sparse.csc_matrix[numpy.float64]: ...
    def values(self) -> numpy.ndarray[numpy.float64]: ...
