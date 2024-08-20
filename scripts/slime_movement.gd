extends CharacterBody2D

@export var player: String

@onready var texture: AnimatedSprite2D = %"SlimeTexture"
@onready var aura: Sprite2D = get_node("Aura")

@onready var default_hitbox: CollisionShape2D = get_node("SlimeHitboxDefault")
@onready var ducked_hitbox: CollisionShape2D = get_node("SlimeHitboxDucked")
@onready var fall_hitbox: CollisionShape2D = get_node("SlimeHitboxFall")
@onready var right_jump_hitbox: CollisionShape2D = get_node("SlimeHitboxRightJump")
@onready var left_jump_hitbox: CollisionShape2D = get_node("SlimeHitboxLeftJump")
@onready var right_attack_hurtbox: CollisionShape2D = get_node("HurtboxRight/HurtboxRightCollision")
@onready var left_attack_hurtbox: CollisionShape2D = get_node("HurtboxLeft/HurtboxLeftCollision")

signal change_size(new_size: int)

const SPEED = 700.0
const DASH_SPEED = 1300.0
const JUMP_VELOCITY = -1000.0

enum State {default, dash, jump, duck, fall, attack}

var current_state: State = State.default
var xspawn: float

var nofall: bool = false

@export var size: float = 60:
	get:
		return size
	set(value): 
		var oldsize = size
		size = clamp(value, 5, 100)
		scale =  Vector2.ONE * size * 0.3
		change_size.emit(size)
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
		if is_on_floor():
			position.y -= (size-oldsize)*2.5
			velocity.y = 100
			nofall = true
			get_tree().create_timer(0.1).timeout.connect(stop_nofall)

func stop_nofall():
	nofall = false

func end_head_bump():
	current_state = State.default
	right_attack_hurtbox.disabled = true
	left_attack_hurtbox.disabled = true
	hitbox_to_normal()
	texture.play("slime-idle")

func respawn():
	position = Vector2(xspawn, -1000)
	size = 60
	velocity = Vector2.ZERO

func set_color(color: Color):
	texture.self_modulate = color

func _ready() -> void:
	size = size
	xspawn = position.x

func hitbox_to_normal() -> void :
	default_hitbox.disabled = false
	fall_hitbox.disabled = true
	ducked_hitbox.disabled = true
	right_jump_hitbox.disabled = true
	left_jump_hitbox.disabled = true

func normal_hitbox_to_jump() -> void:
	default_hitbox.disabled = true
	fall_hitbox.disabled = false

func normal_hitbox_to_right_jump() -> void:
	default_hitbox.disabled = true
	right_jump_hitbox.disabled = false

func normal_hitbox_to_left_jump() -> void:
	default_hitbox.disabled = true
	left_jump_hitbox.disabled = false

func _process(_delta: float) -> void:	
	if Input.is_action_pressed(player + "_dash"):
		current_state = State.dash
		texture.play("slime-dash")
		default_hitbox.disabled = false
		fall_hitbox.disabled = true
		left_jump_hitbox.disabled = true
		right_jump_hitbox.disabled = true
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
	if current_state == State.attack: 
		return

	# Mid air physics.
	if not is_on_floor() and not nofall:
		var direction_fall := Input.get_axis(player + "_left", player + "_right")
		if velocity.y > 0 and direction_fall == 0:
			current_state = State.fall
			texture.play("slime-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = false
			left_jump_hitbox.disabled = true
			right_jump_hitbox.disabled = true 
		elif velocity.y > 0 and direction_fall > 0:
			current_state = State.fall
			texture.play("slime-side-jump-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = true
			left_jump_hitbox.disabled = false
			right_jump_hitbox.disabled = true
		elif velocity.y > 0 and direction_fall < 0:
			current_state = State.fall
			texture.play("slime-side-jump-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = true
			left_jump_hitbox.disabled = true
			right_jump_hitbox.disabled = false
		velocity += get_gravity() * delta
	# Hitting floor animation.
	elif current_state == State.fall and not nofall:
		texture.play("slime-hit-floor")
		hitbox_to_normal()
		default_hitbox.disabled = true
		ducked_hitbox.disabled = false
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
		texture.play("slime-idle")
		hitbox_to_normal()
		if Input.is_action_pressed(player + "_duck"):
			texture.play("slime-hit-floor")
			texture.pause()
			default_hitbox.disabled = true
			ducked_hitbox.disabled = false
			current_state = State.duck

	# Handle jump.
	var direction_jump := Input.get_axis(player + "_left", player + "_right")
	if Input.is_action_just_pressed(player + "_jump") and is_on_floor():
		if direction_jump == 0:
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_jump)
			texture.play("slime-jump-start")
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			move_and_slide()
			return
		# Jump to the right
		elif direction_jump > 0 and Input.is_action_just_pressed(player + "_jump") and is_on_floor():
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_right_jump)
			texture.play("slime-side-jump-start")
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			move_and_slide()
			return
		# Jump to the left
		elif direction_jump < 0 and Input.is_action_just_pressed(player + "_jump") and is_on_floor():
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_left_jump)
			texture.play("slime-side-jump-start")
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
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
		velocity += get_gravity() * delta * 80

	# Headbump attacks
	if Input.is_action_just_pressed(player + "_attack") and is_on_floor():
		current_state = State.attack
		texture.play("slime-headbump")
		if texture.flip_h :
			left_attack_hurtbox.disabled = false
		else :
			right_attack_hurtbox.disabled = false
		get_tree().create_timer(1).timeout.connect(end_head_bump)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(player + "_left", player + "_right")
	if direction and current_state != State.duck:
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
	
	for i in range(get_slide_collision_count()):	
		var collision: KinematicCollision2D = get_slide_collision(i)
		var slime = collision.get_collider()
		if not "player" in slime:
			return
		slime.velocity += collision.get_normal()
		#wip
		
