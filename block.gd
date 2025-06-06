extends StaticBody3D

var health = 100

func take_damage(damage):
    health -= damage
    if health <= 0:
        queue_free()  # Удаляем блок
