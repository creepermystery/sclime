extends Node2D

signal quit_game()

@onready var camera: Camera2D = get_node("Camera")
@onready var p1: Camera2D = get_node("Player1")
@onready var p2: Camera2D = get_node("Player2")

func quit():
	quit_game.emit()

func set_colors(color1, color2):
	get_node("Player1").set_color(color1)
	get_node("Player2").set_color(color2)

func _process(delta: float) -> void:
	
	# camera 
	camera.position = Vector2(0,0)
