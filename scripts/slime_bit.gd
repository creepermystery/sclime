extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func stop_texture() -> void :
	get_node("Texture").pause()

func start_texture(texture: AnimatedSprite2D) -> void :
	if linear_velocity.y == 0 :
		texture.play("touch-ground")
		get_node("Hitbox/Dropping").disabled = true
		get_node("Hitbox/Stopped").disabled = false
		get_node("Timer").start()

func _physics_process(_delta: float) -> void:
	var texture: AnimatedSprite2D = get_node("Texture")
	if linear_velocity.y == 0 :
		if texture.animation == "default":
			start_texture(texture)
		return
	texture.play("default")
	get_node("Hitbox/Dropping").disabled = false
	get_node("Hitbox/Stopped").disabled = true
	
func picked(body):
	get_node("PickupSound").play()
	get_node("Texture").visible = false
	body.size += 10
	await get_tree().create_timer(0.65).timeout
	queue_free()
