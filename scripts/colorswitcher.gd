extends Control

var colors = [Color.LIGHT_CORAL, Color.LIGHT_GREEN, Color.SKY_BLUE, Color.YELLOW, Color.DARK_ORANGE]

@onready var color: int:
	get:
		return color
	set(value):
		color = value 
		if color >= colors.size():
			color = 0
		if color < 0:
			color = colors.size() - 1
		get_node("Sprite").self_modulate = colors[color]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = 1

func next_color():
	color += 1

func prev_color():
	color -= 1
