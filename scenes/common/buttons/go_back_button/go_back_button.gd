extends IconButton

func _ready() -> void:
	button_down.connect(func(): $AnimationPlayer.play("on"))
	button_up.connect(func(): set_activated(_activated))
	pressed.connect(func(): 
		$AnimationPlayer.play("off")
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	)
