# shop_ui.gd
extends CanvasLayer

var player_money = 1000  # Стартовые деньги

func _on_ak47_button_pressed():
    if player_money >= 500:
        player_money -= 500
        get_tree().call_group("player", "equip_weapon", "ak47")  # Передаем тип оружия игроку
        update_money_label()
