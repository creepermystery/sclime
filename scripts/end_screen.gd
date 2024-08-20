extends Control

signal quit()

func player_appear(player: int, color: Color) -> void :
	var player_node: Control
	var player_sprite: TextureRect
	if player == 1:
		player_node = get_node("Player1")
		player_sprite = get_node("Player1/Sprite")
	else :
		player_node = get_node("Player2")
		player_sprite = get_node("Player2/Sprite")
	player_sprite.self_modulate = color
	player_node.visible = true
	


func _on_quit_button_pressed() -> void:
	quit.emit()
