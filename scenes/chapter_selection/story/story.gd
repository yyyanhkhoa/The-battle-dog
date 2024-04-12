class_name Story extends MarginContainer

const CHAPTER_BUTTON: PackedScene = preload("res://scenes/chapter_selection/chapter_button/chapter_button.tscn")

signal chapter_entering

var _story_id: String
func get_story_id() -> String: return _story_id

func _ready() -> void:
	focus_entered.connect(func():
		%HSlideSelection.grab_focus()
	)

func setup(story_dir_path: String, chapter_dir_paths: Array[String]) -> void:
	_story_id = story_dir_path.get_file().split('.')[1]
	%StoryLabel.text = tr("@STORY_%s" % _story_id)
	
	var selected_index = Data.save_data['story_selected_chapters'].get(_story_id)
	%HSlideSelection.setup(
		_create_chapter_buttons(chapter_dir_paths), 
		selected_index if selected_index != null else 0
	)
	
func _create_chapter_buttons(chapter_dir_paths: Array[String]) -> Array[Selectable]:
	var chapter_buttons: Array[Selectable] = []
	var index = 0
	for chapter_dir_path in chapter_dir_paths:
		var chapter_id := chapter_dir_path.get_file().split('.')[1]
		var chapter_image_path := chapter_dir_path + "/cover_image.png"
		var chapter_button: ChapterButton = CHAPTER_BUTTON.instantiate()
		chapter_button.setup(chapter_id, load(chapter_image_path))
		chapter_button.chapter_entering.connect(func():
			chapter_entering.emit()
			if not Data.save_data['chapters'].has(chapter_id):
				Data.save_data['chapters'][chapter_id] = {
					'passed_stage': -1,
					'selected_stage': 0,
					'completed': false,
				}
			
			Data.save_data['story_selected_chapters'][_story_id] = index
			Data.save_data['selected_chapter_id'] = chapter_id
			Data.save_data['selected_story_id'] = _story_id
			Data.save_data['selected_chapter_dir_path'] = chapter_dir_path
			Data.save()
		)
		chapter_buttons.append(chapter_button)
		index += 1
		
	return chapter_buttons
