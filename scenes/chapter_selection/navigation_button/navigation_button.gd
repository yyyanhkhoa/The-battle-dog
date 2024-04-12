extends TextureButton

func set_activated(ativated: bool) -> void:
	$AnimationPlayer.play("on" if ativated else "off")
