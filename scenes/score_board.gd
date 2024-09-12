extends Control

func _ready() -> void:
	if GlobalVar.silentwolf_configured:
		var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
		print(sw_result.scores)
		#$Label2.text = str(sw_result.scores)
