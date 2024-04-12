extends CanvasLayer

var _prev_time_scale: float 

func _ready() -> void:
	
	visibility_changed.connect(func(): 
		if visible: 
			_prev_time_scale = Engine.time_scale
			Engine.time_scale = 1
		else:
			Engine.time_scale = _prev_time_scale
	)
	
	$Panel/Panel/CloseButton.pressed.connect(_on_close_menu)
	$Panel/Panel/EscapeBattleButton.pressed.connect(_on_escape_battle)
	$Panel/Panel/ToMainMenuButton.pressed.connect(_on_to_main_menu)

func _on_close_menu() -> void:	
	get_tree().paused = false
	hide()
	
func _on_escape_battle() -> void:
	Engine.time_scale = 1
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file.call_deferred("res://scenes/dogbase/dogbase.tscn")
	
func _on_to_main_menu() -> void:
	Engine.time_scale = 1
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file.call_deferred("res://scenes/start_menu/main.tscn")

func _exit_tree() -> void:
	get_tree().paused = false
	
