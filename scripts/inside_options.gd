extends ReferenceRect

@onready var actioncont := load("res://scenes/action_confirm_container.tscn")
@onready var confirmtext := load("res://scenes/confirmation_text.tscn")
var currentaction := ""
var new_actioncont
var new_confirmedtext

func _on_notice_toggled(toggled_on: bool) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if toggled_on:
		%MusicToggle.text = "Music : On"
		AudioServer.set_bus_mute(bus_idx, false)
	else:
		%MusicToggle.text = "Music : Off"
		AudioServer.set_bus_mute(bus_idx, true)

func instantiate_action(node):
	%ResetName.disabled = true
	%ResetHighScore.disabled = true
	new_actioncont = actioncont.instantiate()
	node.add_sibling(new_actioncont)
	new_actioncont.actionconfirmed.connect(_on_action_confirmed)
	new_actioncont.actioncancelled.connect(_on_action_cancelled)

func _on_reset_name_pressed() -> void:
	if new_confirmedtext:
		new_confirmedtext.queue_free()
		new_confirmedtext = null
	instantiate_action(%ResetName)
	new_actioncont.change_text("Are you sure you want to\nreset your leaderboard name?")
	currentaction = "resetname"

func _on_reset_high_score_pressed() -> void:
	if new_confirmedtext:
		new_confirmedtext.queue_free()
		new_confirmedtext = null
	instantiate_action(%ResetHighScore)
	new_actioncont.change_text("Are you sure you want to\nreset your local high score?")
	currentaction = "resethighscore"

func _on_action_confirmed():
	match (currentaction):
		"resetname":
			GlobalVar.playername = ""
			SaveSystem.set_var("player_name", "")
			SaveSystem.save()
			#new_actioncont.hide_buttons_change_text("Name reset succeed.")
			new_actioncont.queue_free()
			new_actioncont = null
			new_confirmedtext = confirmtext.instantiate()
			%ResetName.add_sibling(new_confirmedtext)
			new_confirmedtext.text = "Name reset succeed."
			%ResetHighScore.disabled = false
		"resethighscore":
			GlobalVar.high_score = 0
			SaveSystem.set_var("highscore", 0)
			SaveSystem.save()
			#new_actioncont.hide_buttons_change_text("Highscore reset succeed.")
			new_actioncont.queue_free()
			new_actioncont = null
			new_confirmedtext = confirmtext.instantiate()
			%ResetName.add_sibling(new_confirmedtext)
			new_confirmedtext.text = "Highscore reset succeed."
			%ResetName.disabled = false

func _on_action_cancelled():
	currentaction = ""
	new_actioncont.queue_free()
	%ResetName.disabled = false
	%ResetHighScore.disabled = false
