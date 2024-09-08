extends Node

@export var character : CharacterBody2D
@export var every_enemies : Array[PackedScene]

var score := 0

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
	else:
		%Label.hide()
		
	character.key_press.connect(_on_key_press)
	if character.has_signal("swap_direction"): character.swap_direction.connect(_on_swap_direction)
	if character.has_signal("add_score"): character.add_score.connect(_on_add_score)
	$AudioStreamPlayer.get_stream().set_loop(true)

func _on_swap_direction(is_on_cooldown : bool):
	#if is_on_cooldown: %SwapButton.set_modulate(Color("7070709f"))
	#else: %SwapButton.set_modulate(Color("ffffff9f"))
	if is_on_cooldown:
		%SwapButton.start_timer()

func _on_key_press(key : String):
	%Label.text = "Key Press: " + key
	$LabelResetTimer.stop()
	$LabelResetTimer.start(1)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("labelbounce")

func _on_label_reset_timer_timeout() -> void:
	%Label.text = "Key Press: "

func decide_spawn_timer() -> float:
	var enemy_amount = %Enemies.get_child_count()
	return randf_range(0.75 + enemy_amount * 0.3, 1.5 + enemy_amount * 0.5)

func _on_enemy_spawn_timer_timeout() -> void:
	var spawners : Array= %Spawners.get_children()
	var spawner_to_remove : Marker2D
	for spawner in spawners:
		if spawner.direction_from == character.current_direction and spawner.lane == character.current_lane:
			spawner_to_remove = spawner
			break
	spawners.erase(spawner_to_remove)
	var spawner_node : Marker2D = spawners.pick_random()
	var new_enemy : CharacterBody2D = every_enemies.pick_random().instantiate()
	new_enemy.global_position = spawner_node.global_position
	#print("new enemy spawned at %v" % new_enemy.global_position)
	%Enemies.add_child(new_enemy)
	new_enemy.adjust_spawn_direction(spawner_node.direction_from)
	new_enemy.start_wall_cooldown()
	$EnemySpawnTimer.start(decide_spawn_timer())

func _on_add_score(added_score : int):
	score += added_score
	%ScoreLabel.text = "Score	: %d" % score
	%ShakerComponent2D.is_playing = true
