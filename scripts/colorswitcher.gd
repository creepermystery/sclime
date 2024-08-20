extends Control

var colors = [Color.REBECCA_PURPLE, Color.LIGHT_GREEN, Color.LIGHT_CORAL, Color.SKY_BLUE, Color.YELLOW, Color.DARK_ORANGE, Color.TEAL, Color.CYAN, Color.MAGENTA, Color.WHITE, Color.DIM_GRAY, Color.DARK_SALMON]

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
