extends VBoxContainer

signal actionconfirmed
signal actioncancelled

func _on_confirm_action_pressed() -> void:
	actionconfirmed.emit()
	
func _on_cancel_action_pressed() -> void:
	actioncancelled.emit()

func hide_buttons_change_text(new_text : String):
	$ButtonCont.hide()
	$Title.text = new_text
	
func change_text(new_text):
	$Title.text = new_text
