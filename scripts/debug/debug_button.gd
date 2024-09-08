extends TouchScreenButton

var cooldownshadermat : Material

@onready var timer : Timer = $FlipCooldown

func _ready() -> void:
	cooldownshadermat = get_material()
	#cooldownshadermat.set_shader_parameter("cooldown_progress", 0)

func set_cooldown_progress(progress : float) -> void:
	cooldownshadermat.set_shader_parameter("cooldown_progress", progress)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debugpress"):
		#$"../../../References".visible = !$"../../../References".visible
		for node in get_tree().get_root().get_node("Pixelated2DMain").get_children():
			if node.is_in_group("references"):
				node.visible = !node.visible
	if timer.get_time_left() > 0:
		set_cooldown_progress(timer.get_time_left() / timer.get_wait_time())

func start_timer():
	timer.start()

func _on_flip_cooldown_timeout() -> void:
	pass # Replace with function body.
