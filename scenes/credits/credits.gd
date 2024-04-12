class_name Credits extends Control

signal goback_pressed

func _ready() -> void:
	%GoBackButton.pressed.connect(func(): 
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
		goback_pressed.emit()
	)
