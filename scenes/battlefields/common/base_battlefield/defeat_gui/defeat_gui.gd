extends CanvasLayer

func _ready() -> void:
	$AnimationPlayer.play("default")
	var return_button = $Control/Panel/Button 
	return_button.pressed.connect(_go_to_dog_base)

func _go_to_dog_base():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")
