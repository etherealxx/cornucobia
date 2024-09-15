extends Node2D

func _draw():
	var statuscolor := Color.DARK_RED
	if GlobalVar.silentwolf_configured:
		statuscolor = Color.DARK_GREEN
		
	draw_circle(Vector2(30.0, 30.0), 10, statuscolor)
