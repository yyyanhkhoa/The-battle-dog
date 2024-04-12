class_name IconButton extends TextureButton

var _activated := false

func _ready() -> void:
	button_down.connect(func():
		$AnimationPlayer.play("button_down")
	)
	button_up.connect(
		func(): set_activated(_activated) 
	)
	
	pressed.connect(func():
		set_activated(!_activated)
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	)

func set_activated(activated: bool) -> void:
	_activated = activated
	
	if disabled:
		return
		
	$AnimationPlayer.play("on" if activated else "off")

func _set(property: StringName, value: Variant) -> bool:
	if property != "disabled":
		return false
		
	if value == true:
		$AnimationPlayer.play("disabled")
	else:
		set_activated.call_deferred(_activated)
		
	return false

	
