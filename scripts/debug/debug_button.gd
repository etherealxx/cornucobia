extends TouchScreenButton

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debugpress"):
		#$"../../../References".visible = !$"../../../References".visible
		for node in get_tree().get_root().get_node("Pixelated2DMain").get_children():
			if node.is_in_group("references"):
				node.visible = !node.visible
