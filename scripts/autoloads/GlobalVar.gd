extends Node

var score := 0
var high_score := 0
var silentwolf_api_key_path = "res://scripts/api_keys/silentwolf_api_key.gd"

func initialize_leaderboard():
	if FileAccess.file_exists(silentwolf_api_key_path):
		var sw_api_script = load("res://scripts/api_keys/silentwolf_api_key.gd")
		var sw_api_node = Node.new()
		sw_api_node.set_script(sw_api_script)
		for property in sw_api_node.get_property_list():
			if sw_api_node.has_method("get_api_key"):
				var sw_config ={
					"api_key": sw_api_node.get_api_key(),
					"game_id": sw_api_node.get_game_id(),
					"log_level": 1
				}
				SilentWolf.configure(sw_config)
				
