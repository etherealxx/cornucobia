extends Node

@export var character : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale down the window accordingly if the project being ran in Desktop (not Android)
	if OS.get_name() != "Android":
		var usable_screen_height = DisplayServer.screen_get_usable_rect().size.y
		var usable_screen_height_safe = 2 * usable_screen_height - DisplayServer.screen_get_size().y
		var base_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
		if usable_screen_height_safe < base_viewport_height:
			var width_scaled = ProjectSettings.get_setting("display/window/size/viewport_width") * usable_screen_height_safe / base_viewport_height
			#var window_x_pos = DisplayServer.window_get_position().x
			DisplayServer.window_set_size(Vector2i(width_scaled, usable_screen_height_safe))
			@warning_ignore("integer_division")
			DisplayServer.window_set_position(	Vector2i(DisplayServer.screen_get_size().x / 2 - width_scaled / 2,
												DisplayServer.screen_get_size().y - usable_screen_height))
	
	character.key_press.connect(_on_key_press)
	$AudioStreamPlayer.get_stream().set_loop(true)

func _on_key_press(key : String):
	%Label.text = "Key Press: " + key
	$LabelResetTimer.stop()
	$LabelResetTimer.start(1)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("labelbounce")

func _on_label_reset_timer_timeout() -> void:
	%Label.text = "Key Press: "
