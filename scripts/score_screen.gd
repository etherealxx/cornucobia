extends Node2D

var is_loading_leaderboard

@export_file("*.tscn") var maingameplay_scn_path : String
@export var debug_accept_windows := false

func _ready() -> void:
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	
func _on_btn_submit_score_released() -> void: #@TODO implement check if player release the button when their finger were there
	%Notice.hide()
	if (GlobalVar.silentwolf_configured and not is_loading_leaderboard) or debug_accept_windows:
		is_loading_leaderboard = true
		if not GlobalVar.is_tos_accepted:
			toggle_modulator()
			%AcceptTOSPrivacy.show()
			return
		if GlobalVar.playername.is_empty():
			toggle_modulator()
			%InsertName.hide()
			return
		if GlobalVar.silentwolf_configured:
			await SilentWolf.Scores.save_score("Ether", GlobalVar.score)
			%ScoreBoard.load_leaderboard()
			await %ScoreBoard.leaderboard_loaded
			$BtnSubmitScore.hide()
		is_loading_leaderboard = false

func toggle_modulator():
	%ScoreCanvasModulate.visible = !%ScoreCanvasModulate.visible
	%CanvasModulate.visible = !%CanvasModulate.visible

func _on_accept_tos_privacy_canceled() -> void:
	toggle_modulator()
	%AcceptTOSPrivacy.hide()
	is_loading_leaderboard = false

func _on_accept_tos_privacy_confirmed() -> void:
	GlobalVar.is_tos_accepted = true
	%InsertName.show()

func _on_insert_name_canceled() -> void:
	toggle_modulator()
	%InsertName.hide()
	is_loading_leaderboard = false

func _on_insert_name_confirmed() -> void:	
	GlobalVar.playername = %InsideDialog.get_name()
	if not debug_accept_windows:
		await SilentWolf.Scores.save_score(GlobalVar.playername, GlobalVar.score)
		%ScoreBoard.load_leaderboard()
		await %ScoreBoard.leaderboard_loaded
		$BtnSubmitScore.hide()
	is_loading_leaderboard = false

func _on_btn_play_again_released() -> void:
	GlobalVar.reset_scores()
	get_tree().change_scene_to_file(maingameplay_scn_path)
