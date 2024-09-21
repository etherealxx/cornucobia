extends Node

@export var character : CharacterBody2D
@export var every_enemies : Array[PackedScene]
@export_file("*.tscn") var gameover_scene_path : String
@export_file("*.mp3") var gameover_song_path : String

@onready var cornkernel_scn = load("res://scenes/gameplay_scenes/cornkernel.tscn")
@onready var cornsprite = load("res://scenes/gameplay_scenes/cornkernel_earn_sprite.tscn")

var score := 0
var corn_score := 0
var difficulty_score := 1.0
#var hp := 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale down the window accordingly if the project being ran in Desktop (not Android)
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	else:
		%Label.hide()
	
	character.key_press.connect(_on_key_press)
	if character.has_signal("swap_direction"): character.swap_direction.connect(_on_swap_direction)
	if character.has_signal("add_score"): character.add_score.connect(_on_add_score)
	if character.has_signal("add_cornkernel"): character.add_cornkernel.connect(_on_add_cornkernel)
	if character.has_signal("damaged"): character.damaged.connect(_on_damaged)
	%DebugLabel.text = GlobalVar.debuglog
	GlobalAudioPlayer.music_volume(-10.0)
	GlobalVar.initialize_leaderboard()
	GlobalVar.debuglog += "silentwolf configured: %s\n" % GlobalVar.silentwolf_configured

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
	var min_spawn_time = 0.75 + enemy_amount * 0.1
	var max_spawn_time = max(1.0 + enemy_amount * 0.3, min_spawn_time)
	return randf_range(min_spawn_time, max_spawn_time)

func instantiate_from_random_spawner(	spawnergroup_node : Node2D,
										target_groupnode : Node2D,
										array_to_pick : Array[PackedScene]	):
	var spawners : Array = spawnergroup_node.get_children()
	
	# mechanic to prevent enemy spawning at the same floor and facing character are removed
	#var spawner_to_remove : Marker2D
	#for spawner in spawners:
		#if spawner.direction_from == character.current_direction and spawner.lane == character.current_lane:
			#spawner_to_remove = spawner
			#break
	#spawners.erase(spawner_to_remove)
	
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

func _on_add_cornkernel():
	var new_cornsprite = cornsprite.instantiate()
	%Cornsprites.add_child(new_cornsprite)
	new_cornsprite.position = character.position
	var tween = create_tween()
	tween.tween_property(new_cornsprite,
	"position",
	Vector2(804, 250),
	0.6).from_current().set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_after_corn_collected.bind(new_cornsprite))
	
func _after_corn_collected(body):
	corn_score += 1
	%CornkernelLabel.text = "%d" % corn_score
	body.queue_free()
	
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
		for corn in %CornKernels.get_children():
			corn.stop_idle_cooldown_and_go_idle()
		GlobalVar.score = score
		GlobalVar.cornkernel_score = corn_score
		if score > GlobalVar.high_score: GlobalVar.high_score = score
		GlobalAudioPlayer.stop()
		await get_tree().create_timer(2.0, true, true).timeout
		#GlobalVar.next_scene_path = gameoverscene_path
		#get_tree().change_scene_to_file(GlobalVar.loadingscene_path)
		GlobalVar.go_to_scene(gameover_scene_path, gameover_song_path)
	
func _on_cornkernel_spawn_timer_timeout() -> void:
	if character.hp > 0:
		if %CornKernels.get_child_count() < 7: # limit 7 kernels on screen
			instantiate_from_random_spawner(%CornkernelSpawner, %CornKernels, [cornkernel_scn])
		$CornkernelSpawnTimer.start(decide_spawn_timer_cornkernel())
		
func decide_spawn_timer_cornkernel() -> float:
	var enemy_amount = %CornKernels.get_child_count()
	return randf_range(0.75 + enemy_amount * 0.3, 1.5 + enemy_amount * 0.5)

func _on_difficulty_timer_timeout() -> void:
	if character.hp > 0:
		instantiate_from_random_spawner(%EnemySpawners, %Enemies, every_enemies)
		difficulty_score += randf_range(0.1, 0.2)
		$DifficultyTimer.start(5.0 / difficulty_score)
