extends Control

var finalscore

signal leaderboard_loaded

func _ready() -> void:
	%VarmintsScore.text = "Varmints knocked: %d" % GlobalVar.score
	%CorncobsScore.text = "Corn cobs collected: %d" % GlobalVar.corncob_score
	finalscore = GlobalVar.score + GlobalVar.corncob_score
	if finalscore > GlobalVar.high_score: GlobalVar.high_score = finalscore
	%FinalScore.text = "Your Score: %d" % GlobalVar.corncob_score
	%HighScore.text = "High Score: %d" % GlobalVar.high_score
	%ScoreNames.text = ""
	%NameScores.text = ""
	load_leaderboard()

func load_leaderboard():
	if GlobalVar.silentwolf_configured:
		%ScoreNames.text = "(please wait)"
		%NameScores.text = "(please wait)"
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
