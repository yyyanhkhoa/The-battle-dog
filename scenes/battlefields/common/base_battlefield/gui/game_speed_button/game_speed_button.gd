class_name GameSpeedButton extends TextureButton

signal button_toggled

func _ready() -> void:
	pressed.connect(toggle_game_speed)

func toggle_game_speed() -> void:
	var activated = is_actived()
	Engine.time_scale = 1 if activated else 4   	
	$AnimationPlayer.play("off" if activated else "on")
	
	await $Icon.frame_changed.connect(func(): button_toggled.emit())
	
func is_actived() -> bool:
	return Engine.time_scale == 4
	
