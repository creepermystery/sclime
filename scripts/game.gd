extends Node2D

signal quit_game()

func quit():
	quit_game.emit()

func set_colors(color1, color2):
	get_node("Player1").set_color(color1)
	get_node("Player2").set_color(color2)
