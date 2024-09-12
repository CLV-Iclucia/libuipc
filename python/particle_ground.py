import numpy as np
import polyscope as ps
import polyscope.imgui as psim
from pyuipc_loader import pyuipc
from pyuipc_loader import AssetDir
from pyuipc import Vector3, Matrix4x4, Logger
from pyuipc import builtin
from pyuipc.world import *
from pyuipc.engine import *
from pyuipc.constitution import *
from pyuipc.geometry import *

def process_surface(sc: SimplicialComplex):
    label_surface(sc)
    return sc

Logger.set_level(Logger.Level.Warn)

workspace = AssetDir.output_path(__file__)

engine = Engine("cuda", workspace)
world = World(engine)

config = Scene.default_config()
print(config)

scene = Scene(config)

pt = Particle()
spc = SoftPositionConstraint()
scene.constitution_tabular().insert(pt)
scene.constitution_tabular().insert(spc)
scene.contact_tabular().default_model(0.5, 1e9)
default_element = scene.contact_tabular().default_element()

n = 100
Vs = np.zeros((n, 3), dtype=np.float32)
for i in range(n):
    Vs[i][1] = i

Vs = Vs * 0.05 + np.array([0, 0.2, 0])
mesh = pointcloud(Vs)
process_surface(mesh)

radius = 0.01
pt.apply_to(mesh, 1e3, radius)
default_element.apply_to(mesh)

object = scene.objects().create("object")
object.geometries().create(mesh)

g = ground(0)
object.geometries().create(g)

world.init(scene)

sio = SceneIO(scene)
run = False
ps.init()
ps.set_ground_plane_height(0)
s = sio.simplicial_surface()
v = s.positions().view()
mesh = ps.register_point_cloud('obj', v.reshape(-1,3))
mesh.set_radius(radius)
def on_update():
    global run
    if(psim.Button("run & stop")):
        run = not run
        
    if(run):
        world.advance()
        world.retrieve()
        s = sio.simplicial_surface()
        v = s.positions().view()
        mesh.update_point_positions(v.reshape(-1,3))

ps.set_user_callback(on_update)
ps.show()
