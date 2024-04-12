class_name TutorialDog extends Control
## The tutorial dog that appears when the player is in battle for the first time
##
## Note on the AnimationPlayer's "jump_in_left/right_side" animation:[br]
## The DiaglogueLabel and SpeechBubblePointer are both visible and move out of camera
## instead of just simply be hidden is because objects that are hidden won't emit signals,
## but we need to listen to those signals in the code (in this case, it is
## the DialogueLabel's resized signal).

const BARK_SOUND: AudioStream = preload("res://resources/sound/dog_bark.wav") 

const MAX_DIALOGUE_CONTENT_SIZE_X: int = 325

signal dialogue_started
signal dialogue_ended
signal dialogue_line_changed (line_index: int)

enum PLACEMENT { LEFT, RIGHT }

@onready var bubble_pointer_offset: Vector2 = ($DialogueLabel.position + $DialogueLabel.size) - $SpeechBubblePointer.position  
@onready var original_label_y: float = $DialogueLabel.position.y
@onready var dialogue_label := $DialogueLabel as DynamicLabel

var _dialogue_index: int = 0;
var _dialogue_code: String = ""
var _placement: PLACEMENT
var _typo_effect_finsihed = false

func _handle_next_line() -> void:
	if not dialogue_label.typo_effect.finished:
		dialogue_label.typo_effect.finished = true
		return
	
	if _has_next_dialogue_line():
		AudioPlayer.play_sfx(BARK_SOUND, randf_range(1, 1.2))
		_dialogue_next_line()
	else:
		end_dialogue()

func _ready() -> void:
	dialogue_label.gui_input.connect(func(event):
		if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			_handle_next_line()
	)
	
	%DogButton.pressed.connect(_handle_next_line)
	
	set_process_input(false)

## Update bubble pointer position relative to DialogueLabel
func _update_bubble():
	dialogue_label.size.x = 10000
	dialogue_label.size.x = min(dialogue_label.get_content_width(), MAX_DIALOGUE_CONTENT_SIZE_X) + 100
	
	var min_size: Vector2 = dialogue_label.get_minimum_size()
	dialogue_label.size.y = min_size.y
	$SpeechBubblePointer.position = $BubblePointerMarker.position
	
	if _placement == PLACEMENT.RIGHT:
		dialogue_label.position = $SpeechBubblePointer.position - dialogue_label.size + bubble_pointer_offset
		$SpeechBubblePointer.scale.x = abs($SpeechBubblePointer.scale.x)
	else:
		dialogue_label.position = $SpeechBubblePointer.position - Vector2(0, dialogue_label.size.y) + Vector2(-bubble_pointer_offset.x, bubble_pointer_offset.y)
		$SpeechBubblePointer.scale.x = -abs($SpeechBubblePointer.scale.x)

## This will pop up the tutorial dog, and start the dialouge
## dialogue_code is used to get the dialogue lines of certain part of the tutorial
## pause_game: will pause the game while tutorial dog is active
func start_dialogue(dialogue_code: String, placement: PLACEMENT, pause_game: bool = true) -> void:
	$SpeechBubblePointer.position.y = -99999
	$DialogueLabel.position.y = -99999
	
	_dialogue_index = 0
	_dialogue_code = dialogue_code
	_placement = placement

	if pause_game:
		get_tree().paused = true
		
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var left_side := _placement == PLACEMENT.LEFT
		
	$IntroSound.play()
	$AnimationPlayer.play("jump_in_left_side" if left_side else "jump_in_right_side")
	
	await $AnimationPlayer.animation_finished
	_dialogue_next_line()
	
	set_process_input(true)
	$AnimationPlayer.play("dog_idle")
	
	dialogue_started.emit()	
	
## Stop the dialogue and hide the tutorial dog
func end_dialogue() -> void:
	_dialogue_index = 0
	set_process_input(false)

	$OutroSound.play()	
	var left_side := _placement == PLACEMENT.LEFT
	$AnimationPlayer.play("jump_out_left_side" if left_side else "jump_out_right_side")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("hide")
	
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	dialogue_ended.emit()	
	
## Pause the dialogue (user can't proceed the dialogue)
func pause_dialogue() -> void:
	set_process_input(false)

## Go to next dialouge line, returns the index of the dialogue line 
func _dialogue_next_line() -> void:
	_dialogue_index += 1
	var dialogue_text := tr("@%s_%s" % [_dialogue_code, _dialogue_index])
	$DialogueLabel.text = "[typo]%s[/typo]" % dialogue_text
	_update_bubble()	
	dialogue_line_changed.emit(_dialogue_index)

func _has_next_dialogue_line() -> bool:
	var code = "@%s_%s" % [_dialogue_code, _dialogue_index + 1]
	return tr(code) != code
