extends Control

@export_file("*.tscn") var scene_path_to_load := ""
@export_file("*.mp3") var first_music_to_load := ""
@export var loadingbar : ProgressBar

var progress : Array
var early_check_passed := false
var musicfirst := false
var keep_processing := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	early_check_passed = false
	if GlobalVar.firstload:
		musicfirst = true
		if !first_music_to_load.is_empty(): ResourceLoader.load_threaded_request(first_music_to_load)
		#if !scene_path_to_load.is_empty(): ResourceLoader.load_threaded_request(scene_path_to_load)
		#GlobalVar.firstload = false
	else:
		if GlobalVar.next_scene_path.is_empty(): push_error("next scene is empty")
		else:
			scene_path_to_load = GlobalVar.next_scene_path
			if GlobalVar.music_path_to_load:
				if GlobalVar.music_path_to_load == GlobalAudioPlayer.loaded_music_path:	# skips if same music
					ResourceLoader.load_threaded_request(scene_path_to_load)
				else:
					musicfirst = true
					ResourceLoader.load_threaded_request(GlobalVar.music_path_to_load)
			else:
				ResourceLoader.load_threaded_request(scene_path_to_load)
	early_check_passed = true

func load_scene():
	if GlobalAudioPlayer.loaded_music:
		GlobalAudioPlayer.play_loaded(true)
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(scene_path_to_load)
	)

func blue_transition():
	var tween = create_tween()
	tween.tween_property($SkyBlueOnly,
	"self_modulate:a",
	1.0, # from transparent to opaque
	0.3)
	tween.tween_callback(_after_transition)

func _after_transition():
	await get_tree().create_timer(0.5, true, true).timeout
	GlobalVar.firstload = false
	load_scene()
	
# last day gamejam ahh messy code
func _process(_delta: float) -> void:
	if early_check_passed and keep_processing:
		if loadingbar.value <= 100: loadingbar.value += 2.9
		if musicfirst:
			var path_to_load
			if GlobalVar.firstload: path_to_load = first_music_to_load
			else: path_to_load = GlobalVar.music_path_to_load
			ResourceLoader.load_threaded_get_status(path_to_load, progress)
			if progress[0] >= 1.0: # finished loading
				progress[0] = 0.0
				GlobalAudioPlayer.loaded_music = ResourceLoader.load_threaded_get(path_to_load)
				ResourceLoader.load_threaded_request(scene_path_to_load)
				musicfirst = false
		else:
			ResourceLoader.load_threaded_get_status(scene_path_to_load, progress)
			if progress[0] >= 1.0:
				if GlobalVar.firstload:
					if loadingbar.value >= 100:
						await get_tree().create_timer(0.1, true, true).timeout 
						blue_transition()
				else:
					GlobalVar.firstload = false
					load_scene()
