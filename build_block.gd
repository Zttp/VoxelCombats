extends RigidBody3D
class_name BuildBlock

# Настройки
@export var health := 100.0               # Прочность блока
@export var can_connect := true           # Можно ли присоединять
@export var connection_points := []       # Точки соединения (Vector3)
@export var break_force := 500.0         # Сила разрыва соединения

var is_attached := false                  # Присоединён ли к конструкции
var connected_joints := []                # Список соединений
var original_mesh : Mesh                  # Исходный меш для ресета

func _ready():
    original_mesh = $MeshInstance3D.mesh.duplicate()
    setup_collision()

# Настройка коллизии под меш
func setup_collision():
    var shape = $MeshInstance3D.mesh.create_trimesh_shape()
    $CollisionShape3D.shape = shape

# Присоединение к другому блоку
func connect_to(target_block: BuildBlock, connection_pos: Vector3):
    if !can_connect: return
    
    var joint = Generic6DOFJoint3D.new()
    joint.set_node_a(get_path())
    joint.set_node_b(target_block.get_path())
    joint.global_transform.origin = connection_pos
    
    # Настройка ограничений
    joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LIMIT_SOFTNESS, 0.5)
    joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
    
    get_parent().add_child(joint)
    connected_joints.append(joint)
    is_attached = true

# Получение урона
func take_damage(damage: float, impact_point: Vector3):
    health -= damage
    if health <= 0:
        break_block(impact_point)
    else:
        deform_mesh(impact_point, damage / 50.0)

# Деформация меша при ударе
func deform_mesh(impact_point: Vector3, depth: float):
    var mesh_inst = $MeshInstance3D
    var mesh_data = ArrayMesh.new()
    var surf_tool = SurfaceTool.new()
    
    surf_tool.create_from(mesh_inst.mesh, 0)
    var verts = surf_tool.get_vertices()
    
    for i in verts.size():
        var vertex_pos = mesh_inst.to_global(verts[i])
        var distance = vertex_pos.distance_to(impact_point)
        if distance < 0.5:
            verts[i] += (vertex_pos.direction_to(impact_point)) * depth
            
    surf_tool.set_vertices(verts)
    mesh_data = surf_tool.commit()
    mesh_inst.mesh = mesh_data

# Разрушение блока
func break_block(impact_point: Vector3):
    # Отсоединяем все соединения
    for joint in connected_joints:
        joint.queue_free()
    
    # Эффект разрушения
    spawn_debris(impact_point)
    queue_free()

# Создание обломков
func spawn_debris(position: Vector3):
    var debris = original_mesh.instantiate()
    debris.global_transform = global_transform
    debris.apply_impulse((position - global_position).normalized() * 10.0)
    get_parent().add_child(debris)

# Автоматическое определение точек соединения
func auto_setup_connections():
    connection_points.clear()
    var mesh = $MeshInstance3D.mesh
    if mesh is BoxMesh:
        connection_points = [
            Vector3(0, 0.5, 0), 
            Vector3(0, -0.5, 0)
        ]
