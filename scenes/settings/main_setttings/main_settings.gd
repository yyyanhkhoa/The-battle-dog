class_name MainSettings extends Control
signal keybinding_settings_pressed

const DEFAULT_MUSIC_VOLUME: int = 60
const DEFAULT_SFX_VOLUME: int = 50

func _ready() -> void:
	%MusicSlider.value = Data.music_volume
	%MusicSlider.value_changed.connect(func(value: float) -> void: 
		Data.music_volume = value
		%MusicButton.set_mute(value == 0)
	)
	
	%SFXSlider.value = Data.sound_fx_volume
	%SFXSlider.value_changed.connect(func(value: float) -> void: 
		Data.sound_fx_volume = value
		%SFXButton.set_mute(value == 0)
	)
	
	%SFXSlider.drag_ended.connect(func(_value_changed: bool) -> void:
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	)

	Data.mute_music_changed.connect(on_mute_music_changed)
	Data.mute_sound_fx_changed.connect(on_mute_sfx_changed)	
	
	%KeyBindingSettingsButton.pressed.connect(func() -> void:
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		keybinding_settings_pressed.emit()
	)
	
	%DeleteSaveButton.pressed.connect(_on_delete_save_button_pressed)
	%DeleteSavePopup.confirm.connect(_delete_save)
	
	%FullscreenButton.button_pressed = Data.fullscreen
	%FullscreenButton.toggled.connect(_on_fullscreen_toggled)
	
func _exit_tree() -> void:
	Data.mute_music_changed.disconnect(on_mute_music_changed)
	Data.mute_sound_fx_changed.disconnect(on_mute_sfx_changed)	
	
func on_mute_music_changed(mute: bool) -> void:
	if mute:
		%MusicSlider.set_value_no_signal(0)
	elif Data.music_volume > 0:
		%MusicSlider.set_value_no_signal(Data.music_volume) 
	else:
		%MusicSlider.value = DEFAULT_MUSIC_VOLUME
		
func on_mute_sfx_changed(mute: bool) -> void:
		if mute:
			%SFXSlider.set_value_no_signal(0)
		elif Data.sound_fx_volume > 0:
			%SFXSlider.set_value_no_signal(Data.sound_fx_volume) 
		else:
			%SFXSlider.value = DEFAULT_SFX_VOLUME

func _on_fullscreen_toggled(state: bool) -> void:
	GlobalControl.set_fullscreen(state)
	Data.fullscreen = state
	Data.save()

func _on_delete_save_button_pressed() -> void:
	%DeleteSavePopup.popup(tr('@CONFIRM_DELETE_SAVE'), PopupDialog.Type.CONFIRMATION)

func _delete_save() -> void:
	# delete save data but keep some of user preferences
	var keybinding_settings: Dictionary = Data.save_data['settings']['key_binding_overwrites']
	var game_langauge: String = Data.game_language
	var fullscreen: bool = Data.fullscreen
	
	var new_game_save_file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_game_save_data: Dictionary = JSON.parse_string(new_game_save_file.get_as_text()) 
	
	Data.save_data = new_game_save_data
	Data.save_data['settings']['key_binding_overwrites'] = keybinding_settings
	Data.fullscreen = fullscreen
	Data.game_language = game_langauge
	Data.at_start_game_intro = true
	
	Data.save()
	Data.load_settings()
	
	AudioPlayer.stop_current_music()
	get_tree().change_scene_to_file("res://scenes/new_game_preferences/new_game_preferences.tscn")
