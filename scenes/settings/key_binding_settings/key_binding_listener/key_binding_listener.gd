class_name KeyBindingListener extends Panel

## User canceled key binding request 
signal canceled(action: String)

## Listening successful, action and requested input is given
signal ok(action: String, input: InputEvent)

var _action: String
var _event: InputEvent = null

## Setup the key binding listener
## action: the action code. eg: "ui_confirm", "ui_cancel"
func setup(action: String):
	_action = action
	%ActionLabel.text = tr("@KEY_" + action) + " "

func _ready() -> void:
	%CancelButton.pressed.connect(func() -> void:
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		canceled.emit()
		queue_free()
	)
	
	%ConfirmButton.pressed.connect(func() -> void:
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		ok.emit(_action, _event)
		queue_free()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventScreenTouch or event.is_released():
		return
	
	if event.is_action_pressed("ui_cancel_default"):
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		canceled.emit()
		queue_free()
		
	if event.is_action_pressed("ui_confirm_default") and %ButtonContainer.visible:
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		ok.emit(_action, _event)
		queue_free()
		
	_event = event
	
	%InputLabel.text = event.as_text()

	%ButtonContainer.show()
	
	#Stop event propagation
	get_viewport().set_input_as_handled()

