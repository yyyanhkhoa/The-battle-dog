extends BaseIntro

func _ready() -> void:
	super._ready()
	next_text.connect(_handle_next_text)
	text_ending.connect(_handle_text_ending)

func _handle_next_text(text_number: int) -> void:
	if text_number == 2:
		$AnimationPlayer.play("cover1")
		
func _handle_text_ending(text_number: int, is_last_text: bool) -> void:
	if text_number == 5:
		$AnimationPlayer.play("cover2")
	
	elif is_last_text:
		$AnimationPlayer.play("to_chapter_title")
		await get_tree().create_timer(60.0, false).timeout
		handle_finished()
