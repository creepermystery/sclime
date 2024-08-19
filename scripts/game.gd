extends Node2D

signal quit_game()

@export var zoom = 2.3

@onready var background: TextureRect = get_node("Background/Control/TextureRect")
@onready var camera: Camera2D = get_node("Camera")
@onready var p1: CharacterBody2D = get_node("Player1")
@onready var p2: CharacterBody2D = get_node("Player2")


func quit():
	quit_game.emit()

func set_colors(color1, color2):
	get_node("Player1").set_color(color1)
	get_node("Player2").set_color(color2)

func _process(_delta: float) -> void:
	
	# camera 
	camera.position = 0.9*camera.position + 0.1*(p1.position + p2.position)/2 
	var ratio = min( get_viewport_rect().size.x / abs(p1.position.x - p2.position.x) / zoom, \
	 get_viewport_rect().size.y / abs(p1.position.y - p2.position.y) / zoom, 7)
	camera.zoom = Vector2.ONE * (0.2*camera.zoom.x + ratio*0.8)


func _blast_zone_entered(body: Node2D) -> void:
	pass # Replace with function body.
