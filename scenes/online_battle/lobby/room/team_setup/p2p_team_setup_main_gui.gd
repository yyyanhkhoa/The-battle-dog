@tool
extends MainGUI

func _ready() -> void:
	super()
	%TitleLabel.text = tr(title)
	
func _on_go_back_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	hide()
