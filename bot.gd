extends CharacterBody3D

@export var speed = 3.0
var target_player: Node3D
var health = 100

func _ready():
    target_player = get_tree().get_nodes_in_group("player")[0]
    $NavigationAgent3D.target_position = target_player.global_position

func _physics_process(delta):
    if $NavigationAgent3D.is_navigation_finished():
        return
    
    var next_pos = $NavigationAgent3D.get_next_path_position()
    var direction = (next_pos - global_position).normalized()
    velocity = direction * speed
    move_and_slide()
    
    # Простая стрельба в игрока
    if randf() < 0.01:  # 1% шанс выстрела каждый кадр
        $RayCast3D.look_at(target_player.global_position)
        if $RayCast3D.is_colliding() and $RayCast3D.get_collider() == target_player:
            target_player.take_damage(10)

func take_damage(damage):
    health -= damage
    if health <= 0:
        queue_free()
