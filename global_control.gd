extends Node

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_fullscreen") or event.is_action_pressed("ui_fullscreen_default"):
		var is_fullscreen = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED
		set_fullscreen(false if is_fullscreen else true)

func set_fullscreen(state: bool):
	if state == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
