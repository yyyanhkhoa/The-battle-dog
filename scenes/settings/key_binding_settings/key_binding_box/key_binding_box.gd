class_name KeyBindingBox extends PanelContainer

signal key_binding_requested(action: String)

var _action: String

func get_action() -> String:
	return _action

## Setup the key binding box
## action: the action code. eg: "ui_confirm", "ui_cancel"
func setup(action: String):
	%ActionLabel.text = tr("@KEY_%s" % action)
	
	%Button.pressed.connect(func() -> void:
		key_binding_requested.emit(action)
	)
	
	_action = action
	update_ui()

func update_ui():
	var keyName := InputMap.action_get_events(_action)[0].as_text()
	keyName = keyName.substr(0, keyName.find("(")).strip_edges()
	%Button.text = keyName
