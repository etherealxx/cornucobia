@tool
extends TouchScreenButton

var is_emulating_click := false

@onready var btn_click = $ButtonClicked
@onready var btn_unclick = $ButtonUnclicked

@export var button_text := "Text":
	set(new_text):
		button_text = new_text
		update_text()
	get: return button_text

@export var button_size := Vector2(30, 15) : # or 60, 15 also good
	set(new_size):
		button_size = new_size
		update_size()
	get: return button_size

@export var font_color := Color(0,0,0) : # this is flawed, will change to labelsettings later
	set(new_color):
		font_color = new_color
		update_color()
	get: return font_color

@export var btn_update_text_manually: bool:
	set(v): update_text()
	
@export var btn_emulate_click: bool:
	set(v): emulate_click()

func update_color():
	if btn_unclick: btn_unclick.get_node("UnclickedLabel").get_label_settings().set_font_color(font_color)
	if btn_click: btn_click.get_node("ClickedLabel").get_label_settings().set_font_color(font_color)

func update_size():
	if btn_click: btn_click.size = button_size
	if btn_unclick: btn_unclick.size = button_size

func unclick_anim():
	btn_unclick.visible = true
	btn_click.visible = false
	
func click_anim():
	btn_unclick.visible = false
	btn_click.visible = true
	
func emulate_click():
	click_anim()
	queue_redraw()
	await get_tree().create_timer(0.1).timeout
	unclick_anim()
	queue_redraw()
	
func update_text():
	if btn_unclick: btn_unclick.get_node("UnclickedLabel").text = button_text
	if btn_click: btn_click.get_node("ClickedLabel").text = button_text
	
func _ready() -> void:
	#var new_mesh_tex := MeshTexture.new()
	#new_mesh_tex.mesh = PlaceholderMesh.new()
	texture_normal = texture_normal.duplicate()
	texture_pressed = texture_pressed.duplicate()
	material = material.duplicate()
	if btn_unclick:
		btn_unclick.get_node("UnclickedLabel").label_settings = btn_unclick.get_node("UnclickedLabel").get_label_settings().duplicate()
	if btn_click:
		btn_click.get_node("ClickedLabel").label_settings = btn_click.get_node("ClickedLabel").get_label_settings().duplicate()
	if not Engine.is_editor_hint():
		texture_normal.set_image_size(Vector2(btn_unclick.size.x, btn_unclick.size.y))
		texture_pressed.set_image_size(Vector2(btn_click.size.x, btn_click.size.y))
		unclick_anim()
		pressed.connect(click_anim)
		released.connect(unclick_anim)
	update_text()
	update_size()
	update_color()
		
#func _on_pressed() -> void:
	#click_anim()
#
#func _on_released() -> void:
	#unclick_anim()
