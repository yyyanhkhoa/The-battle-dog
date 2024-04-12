class_name ChapterButton extends Selectable

signal chapter_entering

var _accent_stylebox: StyleBoxFlat
var _chapter_id: String

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited)
	_accent_stylebox = get_theme_stylebox("pressed").duplicate() as StyleBoxFlat

func setup(chapter_id: String, image: Texture2D) -> void:
	_chapter_id = chapter_id
	$TextureRect.texture = image
	$Label.text = tr("@CHAPTER_%s" % chapter_id)

func play_enter_chapter_animation() -> void:
	var tween := create_tween()
	var prev_value: int = -1
	
	tween.tween_method(func(value: int):
		if value == prev_value:
			return
		elif value % 2:
			add_theme_stylebox_override("focus", _accent_stylebox)
		else:
			remove_theme_stylebox_override("focus")
	, 0, 11, 0.75)
	
	await tween.finished

## avoid entering chapter while select chapter animation is running
var _first_click: bool = false
func _on_mouse_exited(): _first_click = false
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.double_click:
			_first_click = true
			
		elif event.double_click and _first_click:
			set_process_input(false)
			handle_selected()

func handle_selected() -> void:
	chapter_entering.emit()
	await play_enter_chapter_animation()
	var path := "res://scenes/intros/%s_intro/%s_intro.tscn" % [_chapter_id, _chapter_id]
	
	if FileAccess.file_exists(path):
		get_tree().change_scene_to_file(path)
	else:
		# no intro for this chapter, go to Dog base instead
		get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")
