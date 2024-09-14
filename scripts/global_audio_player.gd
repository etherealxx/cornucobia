extends AudioStreamPlayer

@export var play_at := 0.0
var loaded_music_path : String
var loaded_music : AudioStream

func play_loaded(looping := false):
	if loaded_music:
		if get_stream() == loaded_music: # skips
			return
		set_stream(loaded_music)
		if looping: get_stream().set_loop(true)
		play()
	else:
		push_error("no music loaded")
	
func music_volume(vol : float):
	set_volume_db(vol)
