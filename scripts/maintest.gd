extends Node

@export var character : CharacterBody2D
@export var every_enemies : Array[PackedScene]

@onready var corncob_scn = load("res://scenes/corncob.tscn")

var score := 0
var corncob := 0

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
	if character.has_signal("add_corncob"): character.add_corncob.connect(_on_add_corncob)
	$AudioStreamPlayer.get_stream().set_loop(true)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debugpress"):
		for node in get_children():
			if node.is_in_group("references"):
				node.visible = !node.visible
	elif Input.is_action_just_pressed("debugpress2"):
		%MainCamera.enabled = !%MainCamera.enabled
		%MainCamera.visible = !%MainCamera.visible
		%ZoomedOutCamera.enabled = !%ZoomedOutCamera.enabled
		%ZoomedOutCamera.visible = !%ZoomedOutCamera.visible

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

func decide_spawn_timer_enemy() -> float:
	var enemy_amount = %Enemies.get_child_count()
	return randf_range(0.75 + enemy_amount * 0.3, 1.5 + enemy_amount * 0.5)

func instantiate_from_random_spawner(	spawnergroup_node : Node2D,
										target_groupnode : Node2D,
										array_to_pick : Array[PackedScene]	):
	var spawners : Array= spawnergroup_node.get_children()
	var spawner_to_remove : Marker2D
	for spawner in spawners:
		if spawner.direction_from == character.current_direction and spawner.lane == character.current_lane:
			spawner_to_remove = spawner
			break
	spawners.erase(spawner_to_remove)
	#print(str(spawners.size()))
	var spawner_node : Marker2D = spawners.pick_random()
	var new_enemy : CharacterBody2D = array_to_pick.pick_random().instantiate()
	new_enemy.position = spawner_node.position
	#print("new enemy spawned at %v" % new_enemy.global_position)
	target_groupnode.add_child(new_enemy)
	new_enemy.adjust_spawn_direction(spawner_node.direction_from)
	new_enemy.start_wall_cooldown()

func _on_enemy_spawn_timer_timeout() -> void:
	instantiate_from_random_spawner(%EnemySpawners, %Enemies, every_enemies)
	$EnemySpawnTimer.start(decide_spawn_timer_enemy())

func _on_add_score(added_score : int):
	score += added_score
	%ScoreLabel.text = "Score	: %d" % score
	%ShakerComponent2D.is_playing = false
	%ShakerComponent2D.is_playing = true

func _on_add_corncob():
	corncob += 1
	%CornCobLabel.text = "Corncob	: %d" % corncob
	
func _on_corncob_spawn_timer_timeout() -> void:
	instantiate_from_random_spawner(%CorncobSpawner, %CornCobs, [corncob_scn])
	$CorncobSpawnTimer.start(decide_spawn_timer_corncob())

func decide_spawn_timer_corncob() -> float:
	var enemy_amount = %CornCobs.get_child_count()
	return randf_range(0.75 + enemy_amount * 0.3, 1.5 + enemy_amount * 0.5)
