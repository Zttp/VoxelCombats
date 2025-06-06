# player.gd
func _input(event):
    if event.is_action_pressed("shoot"):
        var ray = $Camera3D/RayCast3D
        ray.force_raycast_update()
        if ray.is_colliding():
            var target = ray.get_collider()
            if target.has_method("take_damage"):
                target.take_damage(25)  # Урон от пистолета
