extends Node

@export var character : CharacterBody2D
@export var every_enemies : Array[PackedScene]
@export_file("*.tscn") var gameover_scene_path : String
@export_file("*.mp3") var gameover_song_path : String

@onready var corncob_scn = load("res://scenes/corncob.tscn")

var score := 0
var corncob := 0
#var hp := 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale down the window accordingly if the project being ran in Desktop (not Android)
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	else:
		%Label.hide()
	
	GlobalVar.initialize_leaderboard()
	character.key_press.connect(_on_key_press)
	if character.has_signal("swap_direction"): character.swap_direction.connect(_on_swap_direction)
	if character.has_signal("add_score"): character.add_score.connect(_on_add_score)
	if character.has_signal("add_corncob"): character.add_corncob.connect(_on_add_corncob)
	if character.has_signal("damaged"): character.damaged.connect(_on_damaged)
	GlobalVar.debuglog += "silentwolf configured: %s\n" % GlobalVar.silentwolf_configured
	%DebugLabel.text = GlobalVar.debuglog
	GlobalAudioPlayer.music_volume(-10.0)

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
	return randf_range(0.75 + enemy_amount * 0.25, 1.5 + enemy_amount * 0.3)

func instantiate_from_random_spawner(	spawnergroup_node : Node2D,
										target_groupnode : Node2D,
										array_to_pick : Array[PackedScene]	):
	var spawners : Array = spawnergroup_node.get_children()
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
	if character.hp > 0:
		instantiate_from_random_spawner(%EnemySpawners, %Enemies, every_enemies)
		$EnemySpawnTimer.start(decide_spawn_timer_enemy())

func _on_add_score(added_score : int):
	score += added_score
	%ScoreLabel.text = "%d" % score
	%ShakerComponent2D.set_custom_target(false)
	%ShakerComponent2D.play_shake()

func _on_add_corncob():
	corncob += 1
	%CornCobLabel.text = "%d" % corncob

func _on_damaged():
	%HPLabel.text = "%d" % character.hp
	#%ShakerComponent2D.set_custom_target(true)
	#var enemy_array : Array[Node2D]
	#for enemy in %Enemies.get_children():
		#enemy_array.append(enemy)
	#%ShakerComponent2D.Targets = enemy_array
	%ShakerComponent2D.play_shake()
	if character.hp <= 0:
		for enemy in %Enemies.get_children():
			if "is_idle" in enemy:
				enemy.stop_idle_cooldown_and_go_idle()
		for corn in %CornCobs.get_children():
			corn.stop_idle_cooldown_and_go_idle()
		GlobalVar.score = score
		GlobalVar.corncob_score = corncob
		if score > GlobalVar.high_score: GlobalVar.high_score = score
		GlobalAudioPlayer.stop()
		await get_tree().create_timer(2.0, true, true).timeout
		#GlobalVar.next_scene_path = gameoverscene_path
		#get_tree().change_scene_to_file(GlobalVar.loadingscene_path)
		GlobalVar.go_to_scene(gameover_scene_path, gameover_song_path)
	
func _on_corncob_spawn_timer_timeout() -> void:
	if character.hp > 0:
		if %CornCobs.get_child_count() < 7: # limit 7 cobs on screen
			instantiate_from_random_spawner(%CorncobSpawner, %CornCobs, [corncob_scn])
		$CorncobSpawnTimer.start(decide_spawn_timer_corncob())
		
func decide_spawn_timer_corncob() -> float:
	var enemy_amount = %CornCobs.get_child_count()
	return randf_range(0.75 + enemy_amount * 0.3, 1.5 + enemy_amount * 0.5)
