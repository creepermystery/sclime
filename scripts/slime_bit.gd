extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func stop_texture(texture: AnimatedSprite2D) -> void :
	texture.pause()

func start_texture(texture: AnimatedSprite2D) -> void :
	if linear_velocity.y == 0 :
		texture.play("touch-ground")
		get_tree().create_timer(1.1).timeout.connect(stop_texture.bind(texture))

func _physics_process(_delta: float) -> void:
	var texture: AnimatedSprite2D = get_node("Texture")
	if linear_velocity.y == 0 :
		return
	texture.play("default")
	get_tree().create_timer(0.1).timeout.connect(start_texture.bind(texture))
	
