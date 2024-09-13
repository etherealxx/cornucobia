extends Node2D

var is_loading_leaderboard

func _ready() -> void:
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()

func _on_btn_submit_score_released() -> void:
	if GlobalVar.silentwolf_configured and not is_loading_leaderboard:
		await SilentWolf.Scores.save_score("Ether", GlobalVar.score)
		is_loading_leaderboard = true
		%ScoreBoard.load_leaderboard()
		await %ScoreBoard.leaderboard_loaded
		is_loading_leaderboard = false

func toggle_modulator():
	%ScoreCanvasModulate.visible = !%ScoreCanvasModulate.visible
	%CanvasModulate.visible = !%CanvasModulate.visible
