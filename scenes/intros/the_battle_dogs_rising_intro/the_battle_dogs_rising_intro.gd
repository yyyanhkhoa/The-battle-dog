extends Node

func _ready() -> void:
	$SkipButton.pressed.connect(_on_skip, CONNECT_ONE_SHOT)
	$AnimationPlayerText.animation_finished.connect(func(_anim_name): 
		$SkipButton.pressed.disconnect(_on_skip)
		_on_finished()
	)

func _on_skip() -> void:
	$AnimationPlayer.pause()
	_on_finished()
	
func _on_finished() -> void:
	$ColorRect.visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($ColorRect, "color:a8", 255, 1.5)
	tween.tween_property($Music, "volume_db", -40, 1.5)
	await tween.finished
	
	if Data.at_start_game_intro:
		Data.at_start_game_intro = false
		get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

