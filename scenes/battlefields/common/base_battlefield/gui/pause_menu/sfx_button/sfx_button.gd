extends TextureButton

var is_mute: bool

func _ready() -> void:
	is_mute = Data.mute_sound_fx
	$AnimationPlayer.play("inactive" if is_mute else "active")
	pressed.connect(
		func(): 
			AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
			set_mute(!is_mute)
	)

func set_mute(state: bool) -> void:
	is_mute = state 
	$AnimationPlayer.play("inactive" if is_mute else "active")
	Data.mute_sound_fx = is_mute
	Data.save()
	
