extends Node

var menu: Node
var game = preload("res://scenes/game.tscn")

func launch_game(color1: Color, color2: Color):
	menu = get_node("Menu")
	remove_child(menu)
	var game_scene = game.instantiate()
	add_child(game_scene)
	game_scene.quit_game.connect(quit_game)
	game_scene.set_colors(color1, color2)

func quit_game():
	if menu:
		remove_child(get_child(0))
		add_child(menu)
