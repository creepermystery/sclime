extends Control

signal launch(color1: Color, color2: Color)

@onready var _p1 := get_node("Player1")
@onready var _p2 := get_node("Player2")

func launch_game():
	launch.emit(_p1.colors[_p1.color], _p2.colors[_p2.color])

func quit():
	get_tree().quit(0)
