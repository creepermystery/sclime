extends CharacterBody2D


@export var player: String

@onready var texture: AnimatedSprite2D = %"SlimeTexture"
@onready var aura: Sprite2D = get_node("Aura")

@onready var default_hitbox: CollisionShape2D = get_node("SlimeHitboxDefault")
@onready var ducked_hitbox: CollisionShape2D = get_node("SlimeHitboxDucked")
@onready var fall_hitbox: CollisionShape2D = get_node("SlimeHitboxFall")

const SPEED = 700.0
const DASH_SPEED = 1300.0
const JUMP_VELOCITY = -1000.0

enum State {default, dash, jump, duck, fall, dead}

var current_state: State = State.default

@export var size: float = 60:
	get:
		return size
	set(value): 
		size = clamp(value, 5, 100)
		scale =  Vector2.ONE * value * 0.3
		if not aura: 
			return
		if size > 50:
			aura.self_modulate = Color.TRANSPARENT
			collision_mask = 3
		elif size > 17:
			aura.self_modulate = Color(255, 255, 0, 0.3)
			collision_mask = 7
		else :
			aura.self_modulate = Color(255, 255, 0, 0.8)
			collision_mask = 15

func set_color(color: Color):
	texture.self_modulate = color

func _ready() -> void:
	size = size

func jump_hitbox_to_normal() -> void :
	default_hitbox.disabled = false
	fall_hitbox.disabled = true

func normal_hitbox_to_jump() -> void:
	default_hitbox.disabled = true
	fall_hitbox.disabled = false

func _process(_delta: float) -> void:	
	if Input.is_action_pressed(player + "_dash"):
		current_state = State.dash
		texture.play("slime-dash")
		default_hitbox.disabled = false
		fall_hitbox.disabled = true
		ducked_hitbox.disabled = true
		get_tree().create_timer(0.375).timeout.connect(dash_end)

func dash_end() -> void:
	if is_on_floor():
		current_state = State.default
		texture.play("slime-idle")
		default_hitbox.disabled = false
		fall_hitbox.disabled = true
		ducked_hitbox.disabled = true
	else:
		current_state = State.default
		texture.play("slime-jump-start")
		texture.frame = 7
		default_hitbox.disabled = true
		fall_hitbox.disabled = false
		ducked_hitbox.disabled = true

func _physics_process(delta: float) -> void:

	# Dash physics.
	if current_state == State.dash :
		var _direction = -1 if texture.flip_h else 1
		velocity.x = DASH_SPEED * _direction
		move_and_slide()
		return

	# Mid air physics.
	if not is_on_floor():
		if velocity.y > 0:
			current_state = State.fall
			texture.play("slime-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = false
		velocity += get_gravity() * delta
	# Hitting floor animation.
	elif current_state == State.fall :
		texture.play("slime-hit-floor")
		fall_hitbox.disabled = true
		ducked_hitbox.disabled = false
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
		texture.play("slime-idle")
		default_hitbox.disabled = false
		ducked_hitbox.disabled = true
		if Input.is_action_pressed(player + "_duck"):
			texture.play("slime-hit-floor")
			texture.pause()
			default_hitbox.disabled = true
			ducked_hitbox.disabled = false
			current_state = State.duck
	
	# Handle jump.
	if Input.is_action_just_pressed(player + "_jump") and is_on_floor():
		current_state = State.jump
		get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_jump)
		texture.play("slime-jump-start")
		velocity.y = JUMP_VELOCITY
		get_tree().create_timer(0.6).timeout.connect(jump_hitbox_to_normal)
		move_and_slide()
		return

	# Handle duck.
	if Input.is_action_just_pressed(player + "_duck") and is_on_floor():
		texture.play("slime-hit-floor")
		texture.pause()
		default_hitbox.disabled = true
		ducked_hitbox.disabled = false
		current_state = State.duck
		move_and_slide()
		return
	elif Input.is_action_just_released(player + "_duck") and current_state == State.duck and is_on_floor() :
		texture.play("slime-hit-floor")
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
		default_hitbox.disabled = false
		ducked_hitbox.disabled = true
		texture.play("slime-idle")
	# Fastfall
	elif Input.is_action_just_pressed(player + "_duck") and not is_on_floor():
		velocity += get_gravity() * delta * 30
		

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(player + "_left", player + "_right")
	if direction and current_state != State.duck :
		velocity.x = direction * SPEED
	elif direction and current_state == State.duck:
		velocity.x = direction * SPEED / 3
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
