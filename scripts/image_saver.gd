@tool
extends Node

@export var node_with_image_texture : Node
@export var texture_property_path : String
@export_dir var save_directory : String

# requires addon
@export var btn_save_image: bool:
	set(v): save_image()

func save_image():
	print("Button pressed")
	if node_with_image_texture:
		var property_with_image = node_with_image_texture.get(texture_property_path)
		if property_with_image is Texture2D:
			var image : Image = property_with_image.get_image()
			var saved_file_path = save_directory.path_join("image.png")
			var errorcheck = image.save_png(saved_file_path)
			if errorcheck == 0:
				print("image saved to: " + saved_file_path)
			else:
				print("error:" + str(errorcheck))
