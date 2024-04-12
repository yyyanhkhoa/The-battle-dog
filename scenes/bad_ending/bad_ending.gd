extends Panel


func _ready() -> void:
	if not Data.dogs.has("batter_dog"):
		Data.unlock_dog('batter_dog')
		Data.teams[0]['dog_ids'][1] = 'batter_dog'
		Data.save()
		$AnimationPlayer.animation_finished.connect(_batter_dog_inception)
	else:
		$AnimationPlayer.animation_finished.connect(func(_anim):
			get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
		)

func _batter_dog_inception(_anim) -> void:
	$Popup.popup(tr('@BAD_ENDING_DOG_OBTAINED'), PopupDialog.Type.INFORMATION)
	
	await $Popup.ok

	await get_tree().create_timer(1, false).timeout
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	
