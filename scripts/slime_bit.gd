extends RigidBody2D

var eaten := false

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
	if eaten:
		return
	eaten = true
	get_node("Texture").visible = false
	body.size += 10
	disable_hitboxes.call_deferred()
	get_node("PickupSound").play()
	await get_tree().create_timer(0.65).timeout
	queue_free.call_deferred()

func disable_hitboxes():
	get_node("Hitbox/Dropping").disabled = true
	get_node("Hitbox/Stopped").disabled = true
