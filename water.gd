extends StaticBody3D
class_name WaterPhysics

# Настройки
@export var buoyancy_force := 18.0  # Сила плавучести
@export var wave_height := 0.5     # Высота волн
@export var wave_speed := 2.0      # Скорость волн
@export var foam_particles : GPUParticles3D # Ссылка на частицы пены

var submerged_objects := []        # Объекты в воде
var time := 0.0

func _ready():
    # Автоматически ищем частицы, если не заданы
    if !foam_particles:
        foam_particles = $FoamParticles

func _process(delta):
    time += delta
    update_buoyancy()
    update_waves()

# Расчёт плавучести для всех объектов
func update_buoyancy():
    for body in submerged_objects:
        if !is_instance_valid(body):
            submerged_objects.erase(body)
            continue
            
        # Вычисляем погружённый объём (упрощённо)
        var submerged_volume = calculate_submerged_volume(body)
        var force = Vector3.UP * buoyancy_force * submerged_volume
        
        # Применяем силу с демпфированием
        body.apply_force(force, Vector3.ZERO)
        body.linear_velocity *= 0.98  # Водное трение

# Вычисление погружённого объёма
func calculate_submerged_volume(body: PhysicsBody3D) -> float:
    var aabb = body.get_aabb()
    var water_level = global_position.y
    var submerged_height = max(0, water_level - (aabb.position.y))
    return submerged_height * aabb.size.x * aabb.size.z

# Генерация волн через вертексный шейдер
func update_waves():
    var material = $WaterMesh.material_override
    if material:
        material.set_shader_parameter("time", time)
        material.set_shader_parameter("wave_height", wave_height)
        material.set_shader_parameter("wave_speed", wave_speed)

# Обработка входа/выхода из воды
func _on_water_area_body_entered(body):
    if body is PhysicsBody3D and body not in submerged_objects:
        submerged_objects.append(body)
        spawn_foam(body.global_position)

func _on_water_area_body_exited(body):
    submerged_objects.erase(body)

# Эффект брызг
func spawn_foam(position: Vector3):
    if foam_particles:
        foam_particles.restart()
        foam_particles.global_position = position
