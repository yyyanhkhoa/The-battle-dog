extends Control 

const STAGE_BOX_SCENE: PackedScene = preload("res://scenes/maps/base_map/stage_box/stage_box.tscn")

var _stage_ids: Array[String] = []

func _init() -> void:
	_stage_ids = _get_stage_ids()
	
func _get_stage_ids() -> Array[String]:
	var dir := DirAccess.open(Data.selected_chapter_dir_path + "/stages")

	# order asc		
	var file_names: Array[String] = []
	file_names.append_array(dir.get_files())
	file_names.sort_custom(func(a, b):
		return int(a.split(".")[0]) < int(b.split(".")[0])
	)
	
	var stage_ids: Array[String] = []
	stage_ids.assign(
		file_names.map(
			func(file_name: String): return file_name.split(".")[1]
		)
	) 
	return stage_ids
	
func _ready():
	Data.chapter_last_stage = $Stages.get_children().size() - 1
	
	# for debuging purposes
	Data.passed_stage = min(Data.passed_stage, Data.chapter_last_stage)
	Data.selected_stage =  min(Data.selected_stage, Data.chapter_last_stage)
	
	Data.save()
	
	%StoryTitle.text = tr("@STORY_%s" % Data.selected_story_id)
	%ChapterTitle.text = tr("@CHAPTER_%s" % Data.selected_chapter_id)
	%Location.text = tr("@LOCATION_%s" % Data.selected_chapter_id)
	var map_size = %MapSprite.get_rect().size * %MapSprite.scale * $MapSprites.scale
	%DragArea.size = map_size
	
	if (Data.dogs.size() > 1 or Data.skills.size() > 1) and not Data.has_done_map_tutorial:
		var TutorialDogScene: PackedScene = load("res://scenes/maps/base_map/map_tutorial_dog/map_tutorial_dog.tscn")
		var tutorial_dog: MapTutorialDog = TutorialDogScene.instantiate()
		tutorial_dog.setup(%TeamSetupButton)
		%GUI.add_child(tutorial_dog)
	
	var stages = $Stages.get_children()
	for index in stages.size():
		var stage: Stage = stages[index]
		var prev_stage: Stage = stages[index - 1] if index > 0 else null
		var next_stage: Stage = stages[index + 1] if index < stages.size() - 1 else null 
		stage.setup(_stage_ids[index], index, prev_stage, next_stage)
	
	var stage_boxes: Array[Selectable] = []
	for stage in stages.slice(0, Data.passed_stage + 2):
		var stage_box = STAGE_BOX_SCENE.instantiate()
		stage_box.setup(stage)
		stage_boxes.append(stage_box)
		
	%StageChain.setup(stage_boxes, Data.selected_stage, true)
	
	%Tracker.setup(stages, %StageChain, map_size, %DragArea)	
	%Dog.setup(stages[Data.selected_stage], %Tracker)
	
	%GoBackButton.pressed.connect(_go_back_to_dog_base)
	%AttackButton.pressed.connect(_go_to_battlefield)
	%TeamSetupButton.pressed.connect(_go_to_team_setup)

func _go_to_battlefield() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	AudioPlayer.stop_current_music(true, true)
	
	var data := InBattle.load_stage_data()
	
	var battlefield_type: String = data.get('battlefield', 'basic')
	get_tree().change_scene_to_file("res://scenes/battlefields/%s_battlefield/%s_battlefield.tscn" % [
		battlefield_type, battlefield_type
	])
	
func _go_to_team_setup() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/team_setup/team_setup.tscn")

func _go_back_to_dog_base() -> void:
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _exit_tree() -> void:
	Data.save()
