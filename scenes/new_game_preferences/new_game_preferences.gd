extends Control

func _ready() -> void:
	%ButtonEnglish.mouse_entered.connect(func(): TranslationServer.set_locale("en"))
	%ButtonVietnamese.mouse_entered.connect(func(): TranslationServer.set_locale("vi"))
	
	%ButtonEnglish.pressed.connect(
		func():
			AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
			set_language_preference("en")
			show_fullscreen_preference()
			
	)

	%ButtonVietnamese.pressed.connect(
		func():
			AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
			set_language_preference("vi")
			show_fullscreen_preference()
	)
	
	%FullscreenYes.pressed.connect(
		func():
			%YesSound.play()
			set_fullscreen_preference(true)
			show_tutorial_preference()
	)
	
	%FullscreenNo.pressed.connect(
		func():
			AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
			set_fullscreen_preference(false)
			show_tutorial_preference()
	)
	
	var intro_path: String = "res://scenes/intros/%s_intro/%s_intro.tscn" % [
		Data.selected_chapter_id, Data.selected_chapter_id
	]
	
	%TutorialYes.pressed.connect(
		func():
			%TutorialYes.mouse_filter = MOUSE_FILTER_IGNORE		
			%TutorialNo.mouse_filter = MOUSE_FILTER_IGNORE		
			%YesSound.play()
			$AnimationPlayer.play("dog_jump_up")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file(intro_path)
	)
	
	%TutorialNo.pressed.connect(
		func():
			%TutorialYes.mouse_filter = MOUSE_FILTER_IGNORE		
			%TutorialNo.mouse_filter = MOUSE_FILTER_IGNORE		
			AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
			choose_skip_tutorial()
			$AnimationPlayer.play("dog_jump_off")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file(intro_path)
	)

func set_language_preference(language_code: String):
	Data.game_language = language_code
	Data.save()
	TranslationServer.set_locale(language_code) 

func set_fullscreen_preference(state: bool):
	Data.fullscreen = state
	GlobalControl.set_fullscreen(state)
	Data.save()
	
func show_fullscreen_preference():
	%LanguagePreference.hide()
	%FullscreenPreference.show()	
	
func show_tutorial_preference():
	%FullscreenPreference.hide()	
	%TutorialPreference.show()

func choose_skip_tutorial():
	for key in Data.save_data["tutorial"]:
		Data.save_data["tutorial"][key] = true
