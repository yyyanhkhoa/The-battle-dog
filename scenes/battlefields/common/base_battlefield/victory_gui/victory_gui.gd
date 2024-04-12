extends CanvasLayer

@onready var bone_label = $Control/Panel/HBoxContainer/BoneLabel
@onready var return_button = $Control/Panel/Button 

func _ready() -> void:	
	var _stage_data = InBattle.get_stage_data()
	
	$AnimationPlayer.play("default")
	var tween = create_tween()
	
	var reward_bone: int = _stage_data['reward_bone']
	
	var level = InBattle.get_passive_level('bone_reward_up')
	reward_bone = reward_bone + (reward_bone * 0.1 * level)
	
	tween.tween_method(_tween_bone_number, 0, reward_bone, 2).set_delay(1)
	
	Data.passed_stage = max(Data.passed_stage, Data.selected_stage)
	_setup_return_button()
	
	var stage_info = Data.chapter_info.get(Data.selected_stage_id, {})
	if stage_info.has('reward'):
		_handle_stage_reward(stage_info['reward'])
	
	Data.bone += reward_bone
	Data.save()

func _tween_bone_number(value: int):
	bone_label.text = str(value)

func _setup_return_button() -> void:
	if Data.selected_stage >= Data.chapter_last_stage:
		Data.save_data['chapters'][Data.selected_chapter_id]['completed'] = true
		return_button.pressed.connect(_go_to_ending)
	else:
		return_button.pressed.connect(_go_to_dog_base)

func _go_to_dog_base() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file.call_deferred("res://scenes/dogbase/dogbase.tscn")

func _go_to_ending() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	var ending_id := Data.selected_chapter_id + "_ending"
	var ending_path := "res://scenes/endings/%s/%s.tscn" % [ending_id, ending_id]

	if FileAccess.file_exists(ending_path):
		get_tree().change_scene_to_file.call_deferred(ending_path)
	else:
		# no ending for this chapter, go to Dog base instead
		get_tree().change_scene_to_file.call_deferred("res://scenes/dogbase/dogbase.tscn")

func _handle_stage_reward(reward_info: Dictionary) -> void:
	var dog_id = reward_info['dog_id']
	match reward_info['reward_type']:
		'dog':
			if not Data.dogs.has(dog_id):
				Data.unlock_dog(dog_id)
		'ability':
			var ability_id = reward_info['ability_id']
			var abilities := Data.dogs[dog_id]['abilities'] as Array
			if not abilities.has(ability_id):
				abilities.append(ability_id)
