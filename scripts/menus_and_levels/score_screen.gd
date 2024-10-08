extends Node2D

var is_loading_leaderboard = false

@export var main_gameplay_scene : NextSceneRes
@export var main_menu_scene : NextSceneRes
@export var debug_accept_windows := false

func _ready() -> void:
	GlobalAudioPlayer.music_volume(0.0)
	is_loading_leaderboard = true
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	#await %ScoreBoard.offline_score_loaded
	GlobalVar.is_tos_accepted = SaveSystem.get_var("tos_accepted", GlobalVar.is_tos_accepted)
	GlobalVar.playername = SaveSystem.get_var("player_name", GlobalVar.playername)
	if GlobalVar.silentwolf_configured:
		%ScoreBoard.load_leaderboard()
		await %ScoreBoard.leaderboard_loaded
		is_loading_leaderboard = false
	else:
		is_loading_leaderboard = false

func playclick():
	if $ButtonClick.is_inside_tree():
		$ButtonClick.play()

func _on_btn_submit_score_precise_released() -> void:
	%Notice.hide()
	if not is_loading_leaderboard:
		if GlobalVar.silentwolf_configured or debug_accept_windows:
			playclick()
			is_loading_leaderboard = true
			if not GlobalVar.is_tos_accepted:
				toggle_modulator()
				%AcceptTOSPrivacy.show()
				return
			if GlobalVar.playername.is_empty():
				toggle_modulator()
				%InsertName.show()
				return
			if GlobalVar.silentwolf_configured:
				print("PLAYER NAME: %s" % GlobalVar.playername)
				await SilentWolf.Scores.save_score(GlobalVar.playername, %ScoreBoard.finalscore)
				%ScoreNames.text = "(please wait)"
				%NameScores.text = "~\nw\na\ni\nt\n~"
				await get_tree().create_timer(0.1, true, true).timeout # sometimes the leaderboard aren't updated that fast
				%ScoreBoard.load_leaderboard() # next time use the offline sorter method
				await %ScoreBoard.leaderboard_loaded
				$BtnSubmitScore.hide()
			is_loading_leaderboard = false
		else:
			%Notice.show()
	else:
		pass # block clicking while loading leaderboard

func toggle_modulator():
	%ScoreCanvasModulate.visible = !%ScoreCanvasModulate.visible
	%CanvasModulate.visible = !%CanvasModulate.visible

func _on_accept_tos_privacy_canceled() -> void:
	toggle_modulator()
	%AcceptTOSPrivacy.hide()
	is_loading_leaderboard = false
	playclick()

func _on_accept_tos_privacy_confirmed() -> void:
	GlobalVar.is_tos_accepted = true
	SaveSystem.set_var("tos_accepted", true)
	SaveSystem.save()
	%InsertName.show()
	playclick()

func _on_insert_name_canceled() -> void:
	toggle_modulator()
	%InsertName.hide()
	is_loading_leaderboard = false
	playclick()

func _on_insert_name_confirmed() -> void:	
	GlobalVar.playername = %InsideDialog.get_player_name()
	SaveSystem.set_var("player_name", GlobalVar.playername)
	SaveSystem.save()
	print("PLAYER NAME: %s" % GlobalVar.playername)
	toggle_modulator()
	if not debug_accept_windows:
		%ScoreNames.text = "(please wait)"
		%NameScores.text = "~\nw\na\ni\nt\n~"
		await SilentWolf.Scores.save_score(GlobalVar.playername, %ScoreBoard.finalscore)
		%ScoreBoard.load_leaderboard()
		await %ScoreBoard.leaderboard_loaded
		$BtnSubmitScore.hide()
	is_loading_leaderboard = false
	playclick()

func _on_btn_play_again_precise_released() -> void:
	GlobalVar.reset_scores()
	GlobalVar.go_to_nextscene(main_gameplay_scene)
	playclick()

func _on_btn_main_menu_precise_released() -> void:
	GlobalVar.mainmenu_logo_transition = false
	GlobalVar.go_to_nextscene(main_menu_scene)
	playclick()
