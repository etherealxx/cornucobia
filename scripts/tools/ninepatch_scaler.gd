@tool
extends NinePatchRect
@export var before_scale := 1.0
@export var target_scale := 2.0
@export var btn_scale_now: bool:
	set(v): scale_nine_patch()
	
# maybe need to implement reimport with this and reading from the import file
# https://docs.godotengine.org/en/stable/classes/class_editorfilesystem.html#class-editorfilesystem-method-reimport-files
func scale_nine_patch():
	#var ninepatch_texture = get_texture()
	var scale_value : float = target_scale / before_scale
	var prev_region_rect_size : Vector2 = region_rect.size
	var prev_pm_left = patch_margin_left
	var prev_pm_top = patch_margin_top
	var prev_pm_right = patch_margin_right
	var prev_pm_bottom = patch_margin_bottom
	region_rect = Rect2(0.0,0.0, prev_region_rect_size.x * scale_value, prev_region_rect_size.y * scale_value)
	patch_margin_left = prev_pm_left * scale_value
	patch_margin_bottom = prev_pm_bottom * scale_value
	patch_margin_right = prev_pm_right * scale_value
	patch_margin_top = prev_pm_top * scale_value
	before_scale = target_scale
