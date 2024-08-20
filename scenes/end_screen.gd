extends Control

func player_appear(player: int, color: Color) -> void :
	var player_node: Control
	if player == 1:
		player_node = get_node("Player1")
	else :
		player_node = get_node("Player2")
	player_node.self_modulate = color
	player_node.visible = true
	
