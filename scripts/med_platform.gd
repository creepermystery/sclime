extends Node2D

@export var flip: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flip:
		get_node("Sprite2D").flip_h = true
		get_node("Sprite2D").position = Vector2(183, -100)
