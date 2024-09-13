extends Control

@export_file("*.tscn") var scene_path_to_load := ""
@export var loadingbar : ProgressBar

var progress : Array
var early_check_passed := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	early_check_passed = false
	if GlobalVar.firstload:
		if !scene_path_to_load.is_empty(): ResourceLoader.load_threaded_request(scene_path_to_load)
		#GlobalVar.firstload = false
	else:
		if GlobalVar.next_scene_path.is_empty(): push_error("next scene is empty")
		else:
			scene_path_to_load = GlobalVar.next_scene_path
			ResourceLoader.load_threaded_request(scene_path_to_load)
	early_check_passed = true

func load_scene():
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(scene_path_to_load)
	)

func _process(_delta: float) -> void:
	if early_check_passed:
		ResourceLoader.load_threaded_get_status(scene_path_to_load, progress)
		if loadingbar.value <= 100: loadingbar.value += 2.9
		if progress[0] >= 1.0:
			if GlobalVar.firstload:
				if loadingbar.value >= 100:
					await get_tree().create_timer(0.4, true, true).timeout 
					GlobalVar.firstload = false
					load_scene()
			else:
				GlobalVar.firstload = false
				load_scene()
