extends CharacterBody2D

@export var player: String

# Textures
@onready var texture: AnimatedSprite2D = %"SlimeTexture"
@onready var aura: AnimatedSprite2D = get_node("Aura")

# Hitboxes
@onready var default_hitbox: CollisionShape2D = get_node("SlimeHitboxDefault")
@onready var ducked_hitbox: CollisionShape2D = get_node("SlimeHitboxDucked")
@onready var fall_hitbox: CollisionShape2D = get_node("SlimeHitboxFall")
@onready var right_jump_hitbox: CollisionShape2D = get_node("SlimeHitboxRightJump")
@onready var left_jump_hitbox: CollisionShape2D = get_node("SlimeHitboxLeftJump")
@onready var right_attack_hurtbox: CollisionShape2D = get_node("HurtboxRight/HurtboxRightCollision")
@onready var left_attack_hurtbox: CollisionShape2D = get_node("HurtboxLeft/HurtboxLeftCollision")

# Sounds
@onready var damage_sound: AudioStreamPlayer = get_node("Sounds/DamageSound")
@onready var jump_sound: AudioStreamPlayer = get_node("Sounds/JumpSound")
@onready var move_sound: AudioStreamPlayer = get_node("Sounds/MoveSound")
@onready var power_up_sound: AudioStreamPlayer = get_node("Sounds/PowerUpSound")
@onready var splash_sound: AudioStreamPlayer = get_node("Sounds/SplashSound")

signal change_size(new_size: int)
signal damage_sound_signal()

const KNOCKBACK_STRENGTH : float = 2400
const SPEED := 550.0
const DASH_SPEED := 3000.0
const JUMP_VELOCITY := -800.0

enum State {default, dash, jump, duck, fall, attack}

var current_state: State = State.default
var xspawn: float
var old_velocity := Vector2.ZERO
var stomped := false
var is_hurt := false
var is_frame_hurt := false
var old_anim: String
var old_aura_anim: String
var old_frame: int
var can_dash := true
var collisioned := false
var knockback : float = 0
var nofall: bool = false
var splash_sound_enabled: bool = true
var jump_sound_enabled: bool = true
var move_sound_enabled: bool = true
var power_up_sound_enabled: bool = true
var damage_sound_enabled: bool = true

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
			if oldsize < 50 and power_up_sound_enabled :
				power_up_sound.play()
				power_up_sound_enabled = false
				get_tree().create_timer(0.5).timeout.connect(enable_power_up_sound)
		elif size > 17:
			aura.self_modulate = Color(255, 255, 0, 0.3)
			collision_mask = 7
			if oldsize < 17 and power_up_sound_enabled :
				power_up_sound.play()
				power_up_sound_enabled = false
				get_tree().create_timer(0.5).timeout.connect(enable_power_up_sound)
		else :
			aura.self_modulate = Color(255, 255, 0, 0.8)
			collision_mask = 15
		if is_on_floor():
			position.y -= (size-oldsize)*2.5
			velocity.y = 100
			nofall = true
			get_tree().create_timer(0.1).timeout.connect(stop_nofall)

func enable_splash_sound() -> void:
	splash_sound_enabled = true
	
func enable_move_sound() -> void:
	move_sound_enabled = true

func enable_damage_sound() -> void:
	damage_sound_enabled = true

func enable_jump_sound() -> void:
	jump_sound_enabled = true

func enable_power_up_sound() -> void:
	power_up_sound_enabled = true

func stop_nofall():
	nofall = false

func end_head_bump():
	current_state = State.default
	right_attack_hurtbox.disabled = true
	left_attack_hurtbox.disabled = true
	hitbox_to_normal()
	if not is_frame_hurt:
		texture.play("slime-idle")
		aura.play("aura-idle")

func respawn():
	position = Vector2(xspawn, -1000)
	size = 60
	knockback = 0
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
	if Input.is_action_pressed(player + "_dash") and can_dash:
		current_state = State.dash
		texture.play("slime-dash")
		aura.play("aura-dash")
		default_hitbox.disabled = false
		fall_hitbox.disabled = true
		left_jump_hitbox.disabled = true
		right_jump_hitbox.disabled = true
		ducked_hitbox.disabled = true
		can_dash = false
		get_tree().create_timer(0.375).timeout.connect(dash_end)

func dash_end() -> void:
	if is_on_floor():
		current_state = State.default
		texture.play("slime-idle")
		aura.play("aura-idle")
		default_hitbox.disabled = false
		fall_hitbox.disabled = true
		ducked_hitbox.disabled = true
	else:
		current_state = State.default
		texture.play("slime-jump-start")
		aura.play("aura-jump-start")
		texture.frame = 7
		default_hitbox.disabled = true
		fall_hitbox.disabled = false
		ducked_hitbox.disabled = true

func clignote_hurt():
	var key = "-ecrase" if stomped else "-hurt"
	if not is_frame_hurt:
		is_frame_hurt = true
		old_anim = texture.animation
		old_aura_anim = aura.animation
		old_frame = texture.frame
		texture.play("slime" + key)
		aura.play("aura" + key)
	else :
		is_frame_hurt = false
		texture.play(old_anim)
		aura.play(old_aura_anim)
		texture.frame = old_frame
		aura.frame = old_frame

func end_hurt():
		get_node("Hurt").stop()
		is_hurt = false
		if is_frame_hurt:
			clignote_hurt()

func get_collisionned(my_strength, other_strength, normal, _stomped):
	if collisioned or is_hurt:
		return
	collisioned = true
	stomped = _stomped
	get_tree().create_timer(0.5).timeout.connect(reset_collision)
	knockback = lerpf(normal.x * KNOCKBACK_STRENGTH, 0, (size-5)/95) 
	var yknockback = lerpf(normal.y * KNOCKBACK_STRENGTH, 0, (size-5)/95)
	if yknockback < 0: 
		yknockback /= 2
	
	if other_strength > my_strength:
		get_node("Hurt").start()
		is_hurt = true
		get_tree().create_timer(0.8).timeout.connect(end_hurt)
		size -= 3*(other_strength - my_strength)/700
		yknockback *= 1.5
		knockback *= 1.5

	if current_state == State.attack:
		knockback = 0
	else:	
		velocity.y += yknockback

func _physics_process(delta: float) -> void:
	
	# knockback
	for i in range(get_slide_collision_count()):	
		if collisioned or is_hurt:
			break
		var collision: KinematicCollision2D = get_slide_collision(i)
		var slime = collision.get_collider()
		if not "player" in slime:
			break
		damage_sound_signal.emit()
		collisioned = true
		get_tree().create_timer(0.5).timeout.connect(reset_collision)
		
		var normal := collision.get_normal()
		var angle := normal.angle()
		var other_stomped = false
		var my_strength = old_velocity.length()
		var other_strength = slime.old_velocity.length()
		if -PI/4 > angle and -3*PI/4 < angle:
			stomped = false
			other_stomped = true
			if size > slime.size:
				my_strength *= 1 + (size - slime.size ) / 50
		elif (-PI/4 < angle and PI/4 > angle) or (3*PI/4 < angle or -3*PI/4 > angle):
			stomped = false
			if size < slime.size:
				my_strength *= 1 + (slime.size - size) / 50
			else:
				other_strength *= 1 + (size - slime.size ) / 50
		else: 
			stomped = true
			if slime.size > size:
				other_strength *= 1 + (slime.size - size ) / 50
			
		slime.get_collisionned(other_strength, my_strength, -normal, other_stomped)

		# knockback
		knockback = lerpf(normal.x * KNOCKBACK_STRENGTH, 0, (size-5)/95) 
		var yknockback = lerpf(normal.y * KNOCKBACK_STRENGTH, 0, (size-5)/95)
		if yknockback < 0: 
			yknockback /= 2
		
		if other_strength > my_strength:
			get_node("Hurt").start()
			is_hurt = true
			get_tree().create_timer(0.8).timeout.connect(end_hurt)
			size -= 3*(other_strength - my_strength)/700
			yknockback *= 1.5
			knockback *= 1.5
		if current_state == State.attack:
			knockback = 0
		else:	
			velocity.y += yknockback
	
	# reset dash
	if not can_dash and is_on_floor():
		can_dash = true	
	
	# knockback damp
	knockback= lerpf(knockback, 0, min(delta * 2, 1))
	if abs(knockback) < SPEED / 5:
		knockback = 0
	
	# Dash physics.
	if current_state == State.dash and not is_hurt:
		var _direction = -1 if texture.flip_h else 1
		velocity.x = DASH_SPEED * _direction
		custom_move()
		return
	if current_state == State.attack: 
		return

	# Mid air physics.
	if not is_on_floor() and not nofall:
		var direction_fall := Input.get_axis(player + "_left", player + "_right")
		if velocity.y > 0 and direction_fall == 0:
			current_state = State.fall
			if not is_frame_hurt:
				texture.play("slime-fall")
				aura.play("aura-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = false
			left_jump_hitbox.disabled = true
			right_jump_hitbox.disabled = true 
		elif velocity.y > 0 and direction_fall > 0:
			current_state = State.fall
			if not is_frame_hurt:
				texture.play("slime-side-jump-fall")
				aura.play("aura-side-jump-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = true
			left_jump_hitbox.disabled = false
			right_jump_hitbox.disabled = true
		elif velocity.y > 0 and direction_fall < 0:
			current_state = State.fall
			if not is_frame_hurt:
				texture.play("slime-side-jump-fall")
				aura.play("aura-side-jump-fall")
			default_hitbox.disabled = true
			fall_hitbox.disabled = true
			left_jump_hitbox.disabled = true
			right_jump_hitbox.disabled = false
		velocity += get_gravity() * delta
	# Hitting floor animation.
	elif current_state == State.fall and not nofall:
		if not is_frame_hurt:
			texture.play("slime-hit-floor")
			aura.play("aura-hit-floor")
		if splash_sound_enabled:
			splash_sound.play()
			splash_sound_enabled = false
			get_tree().create_timer(0.3).timeout.connect(enable_splash_sound)
		hitbox_to_normal()
		default_hitbox.disabled = true
		ducked_hitbox.disabled = false
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
		if not is_frame_hurt:
			texture.play("slime-idle")
			aura.play("aura-idle")
		hitbox_to_normal()
		if Input.is_action_pressed(player + "_duck") and velocity.y > -0.1:
			if not is_frame_hurt:
				texture.play("slime-hit-floor")
				texture.pause()
				aura.play("aura-hit-floor")
				aura.pause()
			default_hitbox.disabled = true
			ducked_hitbox.disabled = false
			current_state = State.duck
		if velocity.y < JUMP_VELOCITY/2:
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_jump)
			if not is_frame_hurt:
				texture.play("slime-jump-start")
				aura.play("aura-jump-start")
			texture.frame = 1
			aura.frame = 1
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			custom_move()
			return

	# Handle jump.
	var direction_jump := Input.get_axis(player + "_left", player + "_right")
	if Input.is_action_just_pressed(player + "_jump") and is_on_floor():
		if direction_jump == 0:
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_jump)
			if not is_frame_hurt:
				texture.play("slime-jump-start")
				aura.play("aura-jump-start")
			if jump_sound_enabled:
				jump_sound.play()
				jump_sound_enabled = false
				get_tree().create_timer(0.3).timeout.connect(enable_jump_sound)
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			custom_move()
			return
		# Jump to the right
		elif direction_jump > 0 and Input.is_action_just_pressed(player + "_jump") and is_on_floor():
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_right_jump)
			if not is_frame_hurt:
				texture.play("slime-side-jump-start")
				aura.play("aura-side-jump-start")
			if jump_sound_enabled:
				jump_sound.play()
				jump_sound_enabled = false
				get_tree().create_timer(0.3).timeout.connect(enable_jump_sound)
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			custom_move()
			return
		# Jump to the left
		elif direction_jump < 0 and Input.is_action_just_pressed(player + "_jump") and is_on_floor():
			current_state = State.jump
			get_tree().create_timer(0.3).timeout.connect(normal_hitbox_to_left_jump)
			if not is_frame_hurt:
				texture.play("slime-side-jump-start")
				aura.play("aura-side-jump-start")
			if jump_sound_enabled:
				jump_sound.play()
				jump_sound_enabled = false
				get_tree().create_timer(0.3).timeout.connect(enable_jump_sound)
			velocity.y = JUMP_VELOCITY
			get_tree().create_timer(0.6).timeout.connect(hitbox_to_normal)
			custom_move()
			return

	# Handle duck.
	if Input.is_action_just_pressed(player + "_duck") and is_on_floor():
		if not is_frame_hurt:
			texture.play("slime-hit-floor")
			texture.pause()
			aura.play("aura-hit-floor")
			aura.pause()
		default_hitbox.disabled = true
		ducked_hitbox.disabled = false
		current_state = State.duck
		custom_move()
		return
	elif Input.is_action_just_released(player + "_duck") and current_state == State.duck and is_on_floor() :
		if not is_frame_hurt:
			texture.play("slime-hit-floor")
			aura.play("aura-hit-floor")
		await get_tree().create_timer(0.25).timeout
		current_state = State.default
		default_hitbox.disabled = false
		ducked_hitbox.disabled = true
		if not is_frame_hurt:
			texture.play("slime-idle")
			aura.play("aura-idle")
	# Fastfall
	elif Input.is_action_just_pressed(player + "_duck") and not is_on_floor():
		velocity += get_gravity() * delta * 80

	# Headbump attacks
	if Input.is_action_just_pressed(player + "_attack") and is_on_floor() and not is_hurt:
		current_state = State.attack
		if not is_frame_hurt:
			texture.play("slime-headbump")
			aura.play("aura-headbump")
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
		aura.flip_h = false
	elif direction < 0:
		texture.flip_h = true
		aura.flip_h = true
	if direction == 0 and current_state == State.default and is_on_floor() and not is_frame_hurt:
		texture.play("slime-idle")
		aura.play("aura-idle")
	elif direction != 0 and current_state == State.default and is_on_floor() :
		if texture.animation != "slime-move" and not is_frame_hurt:
			texture.play("slime-move")
			aura.play("aura-move")
		if move_sound_enabled:
			move_sound.play()
			move_sound_enabled = false
			get_tree().create_timer(1.06).timeout.connect(enable_move_sound)
	
	move_and_slide()
	
	custom_move()
		
func reset_collision():
	collisioned = false
	
func custom_move():
	velocity.x = lerpf(velocity.x, sign(knockback) * KNOCKBACK_STRENGTH, sqrt(abs(knockback)/KNOCKBACK_STRENGTH))
	if abs(knockback) > abs(velocity.x):
		knockback = velocity.x
	old_velocity = velocity
	move_and_slide()

func on_hurtbox_entered(body):
	if collisioned: 
		return
	if not "player" in body:
		return
	if player == body.player:
		return
	collisioned = true
	get_tree().create_timer(1).timeout.connect(reset_collision)
	var norm = body.velocity.normalized()
	body.velocity.y += -norm.y * KNOCKBACK_STRENGTH
	body.knockback = -norm.x * KNOCKBACK_STRENGTH
	body.size -= 10

func _on_damage_sound_signal() -> void:
	if damage_sound_enabled:
		damage_sound.play()
		damage_sound_enabled = false
		get_tree().create_timer(0.2).timeout.connect(enable_damage_sound)
