extends Control

var finalscore

#signal offline_score_loaded
signal leaderboard_loaded

func _ready() -> void:
	%Notice.hide()
	%NewHighscore.hide()
	%VarmintsScore.text = "Varmints knocked: %d" % GlobalVar.score
	%CorncobsScore.text = "Corn cobs collected: %d" % GlobalVar.corncob_score
	finalscore = GlobalVar.score + GlobalVar.corncob_score
	if finalscore > GlobalVar.high_score:
		GlobalVar.high_score = finalscore
		%NewHighscore.show()
	%FinalScore.text = "Your Score: %d" % finalscore
	%HighScore.text = "High Score: %d" % GlobalVar.high_score
	%ScoreNames.text = ""
	%NameScores.text = ""
	#offline_score_loaded.emit()

func load_leaderboard():
	if GlobalVar.silentwolf_configured:
		%ScoreNames.text = "(please wait)"
		%NameScores.text = "~\nw\na\ni\nt\n~"
		var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
		#print(sw_result.scores)
		var namelines := ""
		var scorelines := ""
		var i := 1
		for scoredict in sw_result.scores:
			namelines += "%d. %s\n" % [i, scoredict["player_name"]]
			scorelines += "%d\n" % [scoredict["score"]]
			i += 1
		%ScoreNames.text = namelines
		%NameScores.text = scorelines
		print("Leaderboard loaded")
		leaderboard_loaded.emit()
	else:
		%Notice.show()
