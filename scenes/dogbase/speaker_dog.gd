extends Control

@onready var bubble_pointer_offset_y: float = ($DialogueLabel.position.y + $DialogueLabel.size.y) - $SpeechBubblePointer.position.y 
@onready var original_label_y: float = $DialogueLabel.position.y + $DialogueLabel.size.y

var dialogue_count: int

const TRANSLATION: Translation = preload("res://resources/translations/translations_speaker_dog.vi.translation") 
const BARK_SOUND: AudioStream = preload("res://resources/sound/dog_bark.wav") 

func _ready() -> void:
	$AnimationPlayer.play("jump_up")
	$AnimationPlayer.animation_finished.connect(
		func(_anim): $AnimationPlayer.play("dog"),
		CONNECT_ONE_SHOT
	)
	
	dialogue_count = TRANSLATION.get_translated_message_list().size()
	
	pick_random_dialogue()
	
	$DogButton.pressed.connect(func():
		AudioPlayer.play_sfx(BARK_SOUND, randf_range(1, 1.2))
		pick_random_dialogue()
	)
	
	$DialogueLabel.resized.connect(_update_bubble)
	
	$DialogueLabel.gui_input.connect(func(event):
		if event is InputEventMouseButton && event.pressed && event.button_index == 1:
			AudioPlayer.play_sfx(BARK_SOUND, randf_range(1, 1.2))
			pick_random_dialogue()
	)
	
## Update bubble pointer position relative to DialogueLabel	
func _update_bubble():
	$DialogueLabel.size.y = 0
	$DialogueLabel.position.y = original_label_y - $DialogueLabel.size.y
	$SpeechBubblePointer.position.y = ($DialogueLabel.position.y + $DialogueLabel.size.y) - bubble_pointer_offset_y

func pick_random_dialogue():
	$DialogueLabel.text = tr("@SPEAKER_DOG_%s" % randi_range(1, dialogue_count))
	_update_bubble()
