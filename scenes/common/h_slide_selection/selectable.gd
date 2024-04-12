class_name Selectable extends Button
## Selectable class uses a conentional "local focus": this focus will not be released until the
## player focus on a different item inside the container. focus from outside of the container
## will not affect this focus. [br]
## To handleuse godot's focus, use focus_entered and focus_exited signals. 

func handle_selected() -> void:
	pass

func handle_local_focus_entered() -> void:
	pass
	
func handle_local_focus_exited() -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL
