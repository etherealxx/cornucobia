extends Node

var score := 0
var high_score := 0
var corncob_score := 0
var silentwolf_api_key_path = "res://scripts/api_keys/silentwolf_api_key.gd"
var silentwolf_configured := false

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
	if FileAccess.file_exists(silentwolf_api_key_path):
		var sw_api_script = load("res://scripts/api_keys/silentwolf_api_key.gd")
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
				"open_scene_on_close": "res://scenes/maintest_real.tscn"
			})
			silentwolf_configured = true
			print("SilentWolf configured.")
				
