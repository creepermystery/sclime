extends CharacterBody2D


@export var player: String

@onready var texture: AnimatedSprite2D = %"slime-texture"
const SPEED = 300.0
const DASH_SPEED = 600.0
const JUMP_VELOCITY = -400.0

enum State {default, dash, jump, duck, fall}

var current_state: State = State.default

func set_color(color: Color):
	texture.self_modulate = color

func _process(delta: float) -> void:
	
	if Input.is_action_pressed(player + "_dash"):
		current_state = State.dash
		texture.play("slime-dash")
		get_tree().create_timer(0.375).timeout.connect(dash_end)

func dash_end() -> void:
	current_state = State.default

func _physics_process(delta: float) -> void:
	
	# Dash physics.
	if current_state == State.dash :
		var direction = -1 if texture.flip_h else 1
		velocity.x = DASH_SPEED * direction
		move_and_slide()
		return
	
	# Mid air physics.
	if not is_on_floor():
		if velocity.y > 0:
			current_state = State.fall
			texture.play("slime-fall")
		velocity += get_gravity() * delta
	# Hitting floor animation.
	elif current_state == State.fall :
		texture.play("slime-hit-floor")
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
	
	# Handle jump.
	if Input.is_action_just_pressed(player + "_jump") and is_on_floor():
		current_state = State.jump
		texture.play("slime-jump-start")
		velocity.y = JUMP_VELOCITY
		move_and_slide()
		return
	# Handle duck.
	if Input.is_action_just_pressed(player + "_duck") and is_on_floor():
		texture.play("slime-hit-floor")
		current_state = State.duck
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(player + "_left", player + "_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


	# Animating directions and idle
	if direction > 0:
		texture.flip_h = false
	elif direction < 0:
		texture.flip_h = true
	if direction == 0 and current_state == State.default and is_on_floor() :
		texture.play("slime-idle")
	move_and_slide()
