extends Node2D

signal quit_game()
signal victory(player: int, color: Color)

@export var zoom = 2.3

@onready var camera: Camera2D = get_node("Camera")
@onready var p1: CharacterBody2D = get_node("Player1")
@onready var p2: CharacterBody2D = get_node("Player2")
@onready var lost_life_sound: AudioStreamPlayer = get_node("SFX/LostLifeSound")

# Preloads
var slime_bits = preload("res://scenes/slime_bits.tscn")
var coeurs = [preload("res://GUI/coeur_1.png"), preload("res://GUI/coeur_2.png"), preload("res://GUI/coeur_3.png")]

var hearts1: int = 3
var hearts2: int = 3

var lost_life_sound_enabled: bool = true

func enable_lost_life_sound() -> void:
	lost_life_sound_enabled = true

func _ready() -> void:
	hearts1 = 3
	hearts2 = 3

func spawn_slime_bits() -> void:
	var bit = slime_bits.instantiate()
	add_child(bit)
	bit.position = Vector2(randf_range(-1500, 2600), -1500)

func quit():
	quit_game.emit()

func set_colors(color1, color2):
	get_node("Player1").set_color(color1)
	get_node("Player2").set_color(color2)
	get_node("GUILayer/Player1/Sprite").self_modulate = color1
	get_node("GUILayer/Player2/Sprite").self_modulate = color2

func _process(_delta: float) -> void:
	
	# camera 
	camera.position = 0.95*camera.position + 0.05*(p1.position + p2.position)/2 
	camera.position.y -= 40 * lerpf(0, 1, max(1500,(p1.position - p2.position).length())/1500 - 1)	
	var ratio = min(min( get_viewport_rect().size.x / abs(p1.position.x - p2.position.x) / zoom, \
	 get_viewport_rect().size.y / abs(p1.position.y - p2.position.y) / zoom), 0.5)
	camera.zoom = Vector2.ONE * (0.5*camera.zoom.x + ratio*0.5)

func update_player_size(size: float, player: String):
	get_node("GUILayer/Player" + player + "/Size").text = str(floor((size - 4.0)/96.0*100.0)) + "%"

func _blast_zone_entered(body: Node2D) -> void:
	if "player" in body:
		if lost_life_sound_enabled :
			lost_life_sound.play()
			lost_life_sound_enabled = false
			get_tree().create_timer(0.5).timeout.connect(enable_lost_life_sound)
		if body.player == "1":
			hearts1 -= 1
			if hearts1 == 0:
				victory.emit(2, get_node("Player2").texture.self_modulate)
				return
			get_node("GUILayer/Player1/Health").texture = coeurs[hearts1 - 1]
			body.respawn()
		else:
			hearts2 -= 1
			if hearts2 == 0:
				victory.emit(1, get_node("Player1").texture.self_modulate)
				return
			get_node("GUILayer/Player2/Health").texture = coeurs[hearts2 - 1]
			body.respawn()
			
