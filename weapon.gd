extends Node3D
class_name Weapon

@export var damage = 25
@export var ammo = 30
@export var max_ammo = 90
@export var fire_rate = 0.1  # Задержка между выстрелами
@export var reload_time = 2.0

var can_shoot = true

func shoot():
    if !can_shoot or ammo <= 0:
        return
    ammo -= 1
    $AnimationPlayer.play("shoot")
    $AudioStreamPlayer3D.play()
    
    if $RayCast3D.is_colliding():
        var target = $RayCast3D.get_collider()
        if target.has_method("take_damage"):
            target.take_damage(damage)
    
    can_shoot = false
    await get_tree().create_timer(fire_rate).timeout
    can_shoot = true

func reload():
    if ammo == max_ammo:
        return
    $AnimationPlayer.play("reload")
    await $AnimationPlayer.animation_finished
    ammo = max_ammo
