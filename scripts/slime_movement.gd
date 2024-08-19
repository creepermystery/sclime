extends CharacterBody2D

@export var player: String

@onready var texture: AnimatedSprite2D = %"slime-texture"
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func set_color(color: Color):
	texture.self_modulate = color

func _process(delta: float) -> void:
	if Input.is_action_pressed(player + "_dash"):
		texture.play("slime-dash")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(player + "_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis(player + "_left", player + "_right")
	
	if direction > 0:
		texture.flip_h = false
		texture.play("default")
	elif direction < 0:
		texture.flip_h = true
		texture.play("default")

	else:
		texture.play("slime-idle")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
			

	move_and_slide()
