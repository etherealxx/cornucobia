extends Node

var score := 0
var high_score := 0
var corncob_score := 0
#var silentwolf_api_key_path = "res://scripts/api_keys/silentwolf_api_key.gd"
var silentwolf_api_key_path = "res://secrets/api_keys/silentwolf_api_key.gd" # "res://secrets/silentwolf_api_key.gd"
var silentwolf_configured := false
var is_tos_accepted := false
var playername := ""
var silentwolf_open_scene_on_close = "res://scenes/main_gameplay_scene.tscn"
var firstload := true
var next_scene_path :=""
var loadingscene_path = "res://scenes/loading_screen.tscn"
var debuglog := ""
var mainmenu_logo_transition := true
var music_path_to_load := ""

func go_to_scene(path := "", _music_path_to_load := ""):
	firstload = false
	next_scene_path = path
	music_path_to_load = _music_path_to_load
	get_tree().change_scene_to_file(loadingscene_path)

# Scale down the window accordingly if the project being ran in Desktop (not Android)
func adaptive_non_android_viewport_scaling():
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

func initialize_leaderboard():
	var dir = DirAccess.open("res://")
	#var checkbool = dir.file_exists(silentwolf_api_key_path)
	#debuglog += "pathexist: %s\n" % checkbool
	if dir.file_exists(silentwolf_api_key_path):
	#var sw_api_script_x = ResourceLoader.load(silentwolf_api_key_path) #TODO clean this mess
	#if sw_api_script_x:
		#debuglog += "got_something\n"
	#if sw_api_script_x:#FileAccess.file_exists(silentwolf_api_key_path):
		#var sw_api_script = load(silentwolf_api_key_path)
		var sw_api_script = ResourceLoader.load(silentwolf_api_key_path)
		var sw_api_node = Node.new()
		sw_api_node.set_script(sw_api_script)
		if sw_api_node.has_method("get_api_key"):
			var sw_config ={
				"api_key": sw_api_node.get_api_key(),
				"game_id": sw_api_node.get_game_id(),
				"log_level": 1
			}
			SilentWolf.configure(sw_config)
			SilentWolf.configure_scores({
				"open_scene_on_close": silentwolf_open_scene_on_close
			})
			silentwolf_configured = true
			print("SilentWolf configured.")
	else:
		debuglog += "file not exist\n"
		
func reset_scores():
	score = 0
	corncob_score = 0
