class_name BaseIntro extends Control

@export var intro_dialogue_code: String = ""
@export var text_fade_duration: float = 0.25
@export var music: AudioStream

@onready var _labels: Array[Label] = [%Label]
@onready var sample_label: Label = %Label.duplicate()

signal next_text(text_number: int)
signal text_ending(text_number: int, is_last_text: bool)

func _enter_tree() -> void:
	%TransitionRect.visible = true

func _ready() -> void:
	AudioPlayer.play_music(music)
	$SkipButton.pressed.connect(handle_finished, CONNECT_ONE_SHOT)
	
	var tween = create_tween()
	tween.tween_property(%TransitionRect, 'color:a8', 0, 2)
	await get_tree().create_timer(1, false).timeout

	_show_intro_text()
		
func _get_message_code(index: int) -> StringName:
	return "@%s_%d" % [intro_dialogue_code, index]

func _show_intro_text() -> void:
	var index := 1
	var code := _get_message_code(index)
	var message := tr(code)
	var tween: Tween
	
	while message != code:
		next_text.emit(index)
		var formats := Global.tr_format(code).split(',', false)
		var messages = message.split('\n', false)
		var line_count = messages.size() 
		
		while _labels.size() < formats.size():
			var label: Label = sample_label.duplicate()
			_labels.append(label)
			%TextContainer.add_child(label)
			
		for i in range(line_count):
			_labels[i].text = messages[i]
			_labels[i].visible = true
			
		for i in range(line_count):
			var label := _labels[i]

			var args = formats[i].split(' ', false)
			if args.size() > 1:
				var variation: String = args[1]
				label.theme_type_variation = variation 
			
			tween = create_tween()
			tween.tween_property(label, 'modulate:a8', 255, text_fade_duration)
			await tween.finished
				
			var delay := float(args[0])
			await get_tree().create_timer(delay, false).timeout

		tween = create_tween()
		tween.set_parallel()
		for i in range(line_count):
			tween.tween_property(_labels[i], 'modulate:a8', 0, text_fade_duration)
			
		index += 1
		code = _get_message_code(index)
		message = tr(code)
		
		text_ending.emit(index - 1, code == message) 
			
		await tween.finished
		for i in range(line_count):
			_labels[i].visible = false
			_labels[i].theme_type_variation = ''
			
func handle_finished() -> void:
	%TransitionRect.visible = true
	%TransitionRect.color = 0x00000000
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(%TransitionRect, "color:a8", 255, 1.5)
	
	if Data.at_start_game_intro:
		AudioPlayer.stop_current_music(true, true, 3)

		await tween.finished
		Data.at_start_game_intro = false
		get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	else:
		var current_music: String = music.resource_path.get_file().split('.')[0]
		var dog_base_music: String = Data.story_info[Data.selected_story_id]['dog_base_theme']
		if dog_base_music != current_music:
			AudioPlayer.stop_current_music(true, true, 3)
		
		await tween.finished
		get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

