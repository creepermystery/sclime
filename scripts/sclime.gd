extends Node

var menu: Node
var game = preload("res://scenes/game.tscn")

func launch_game(color1: Color, color2: Color):
	menu = get_node("Menu")
	remove_child(menu)
	var game_scene = game.instantiate()
	add_child(game_scene)
	game_scene.quit_game.connect(quit_game)
	game_scene.victory.connect(victory_screen)
	game_scene.set_colors(color1, color2)

func quit_game():
	if menu:
		deferred_quit.call_deferred()

func deferred_quit():
	remove_child(get_child(0))
	add_child(menu)

func victory_screen(player: int, color: Color) -> void:
	var end_screen_resource = preload("res://scenes/end_screen.tscn")
	remove_game.call_deferred()
	var end_screen = end_screen_resource.instantiate()
	add_child(end_screen)
	get_child(1).player_appear(player, color)

func remove_game() -> void :
	remove_child(get_child(0))
