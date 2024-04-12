class_name Settings extends Control

## Emitted when the "go back" button is pressed. 
## You can use this singal to switch between the current scene and the settings scene
signal goback_pressed

func _ready() -> void:
	$MainSettings.keybinding_settings_pressed.connect(_show_keybinding_settings)
	
	%GoBackButton.pressed.connect(func() -> void:
		if $MainSettings.visible:
			goback_pressed.emit()
		else:
			# is in keybinding settings
			_show_main_settings()
	)

func _show_keybinding_settings() -> void:
	$MainSettings.hide()
	$KeyBindingSettings.show()
	
func _show_main_settings() -> void:
	$MainSettings.show()
	$KeyBindingSettings.hide()	
