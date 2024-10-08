extends Node2D

@export var main_gameplay_scene : NextSceneRes

var taptrack := 0
var logo_original_y : float
var safe_to_click := false
var skippable := true

func _ready() -> void:
	%QuitDialog.hide()
	$CreditDialog.hide()
	$SkipLabel.hide()
	$OptionDialog.hide()
	%VersionLabel.hide()
	GlobalAudioPlayer.music_volume(0.0)
	$SkyBlueOnlyCover.show()
	if OS.get_name() != "Android":
		GlobalVar.adaptive_non_android_viewport_scaling()
	%BlueSkyParallax.scroll_offset.x = randf_range(0, 3000)
	%CloudParallax.scroll_offset.x = randf_range(0, 3000)
	%GrassParallax.scroll_offset.x = randf_range(0, 3000)
	logo_original_y = $CornucobiaLogo.position.y
	$SkyBlueOnlyCover.position.y = $Camera2D.offset.y
	%VersionLabel.text = "Version : %s" % ProjectSettings.get_setting("application/config/version")
	if GlobalVar.mainmenu_logo_transition:
		$CornucobiaLogo.position.y = 700
		var tween = create_tween()
		tween.tween_property($SkyBlueOnlyCover,
		"self_modulate:a",
		0.0, # from opaque to transparent
		0.3)
		tween.tween_callback(func(): $TransitionTimer.start())
	else:
		skippable = false
		$Camera2D.offset.y = 0.0
		_after_transition()

func playclick():
	if $ButtonClick.is_inside_tree():
		$ButtonClick.play()

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			taptrack += 1
			if skippable:
				if taptrack == 1:
					%SkipLabel.show()
				if taptrack == 2:
					$TransitionTimer.stop()
					$Camera2D.offset.y = 0.0
					_after_transition()

func _on_transition_timer_timeout() -> void:
	skippable = false
	%SkipLabel.hide()
	var tween = create_tween()
	tween.tween_property($Camera2D,
	"offset:y",
	0,
	3.0).from_current().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(%EgothysticalLogo,
	"position:y",
	-500,
	2.0).as_relative().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_delay(0.5)
	tween.parallel().tween_property($CornucobiaLogo,
	"position:y",
	logo_original_y,
	3.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_after_transition)

func _after_transition():
	%EgothysticalLogo.queue_free()
	%SkyBlueOnly.queue_free()
	$SkyBlueOnlyCover.queue_free()
	%SkipLabel.queue_free()
	safe_to_click = true

func toggle_modulator():
	%CanvasModulate.visible = !%CanvasModulate.visible

func toggle_version():
	%VersionLabel.visible = !%VersionLabel.visible

## buttons👇

func _on_btn_play_precise_released() -> void:
	if safe_to_click:
		GlobalVar.go_to_nextscene(main_gameplay_scene)
		playclick()

func _on_btn_options_precise_released() -> void: # opening options menu
	toggle_modulator()
	toggle_version()
	$OptionDialog.show()
	playclick()

func _on_option_dialog_confirmed() -> void: # closing options menu
	toggle_modulator()
	toggle_version()
	$OptionDialog.hide()
	playclick()

func _on_btn_credits_precise_released() -> void: # opening credit menu
	toggle_modulator()
	toggle_version()
	$CreditDialog.show()
	playclick()

func _on_credit_dialog_confirmed() -> void: # closing credit menu
	toggle_modulator()
	toggle_version()
	$CreditDialog.hide()
	playclick()

func _on_btn_quit_precise_released() -> void: # opening quit menu
	toggle_modulator()
	%QuitDialog.show()
	playclick()

func _on_quit_dialog_canceled() -> void:
	toggle_modulator()
	%QuitDialog.hide()
	playclick()

func _on_quit_dialog_confirmed() -> void:
	GlobalAudioPlayer.stop()
	get_tree().quit()
