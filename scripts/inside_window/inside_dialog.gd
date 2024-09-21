extends ReferenceRect

@export var inside_line_edit : LineEdit

func get_player_name() -> String:
	return inside_line_edit.get_text().substr(0,9)
