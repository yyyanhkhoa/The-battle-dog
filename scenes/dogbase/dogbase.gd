extends Control
var TutorialDogScene: PackedScene = preload("res://scenes/dogbase/dogbase_tutorial_dog/dogbase_tutorial_dog.tscn")
var dog_base_music: AudioStream

func _init() -> void:
	var music_id: String = Data.story_info[Data.selected_story_id]['dog_base_theme']
	dog_base_music = load("res://resources/sound/music/%s.mp3" % music_id)

func _ready() -> void:
	if Data.save_data['chapters']['the_battle_dogs_rising']['completed']:
		%SelectChapterIcon.position.x = -%ExpeditionButton.size.x - (%SelectChapterIcon.size.x * 0.5)
	else:
		%ExpeditionButton.theme_type_variation = ""
		%ExpeditionButton.alignment = HORIZONTAL_ALIGNMENT_CENTER
		%SelectChapterIcon.get_parent().queue_free()
		
	AudioPlayer.play_music(dog_base_music, true, true)
	
	var on_go_back_pressed = func():
		var main_gui: = get_tree().current_scene as MainGUI
		main_gui.get_go_back_button().pressed.connect(func():
			AudioPlayer.stop_music(dog_base_music, true, true)
		)
		
	on_go_back_pressed.call_deferred()
	
	if 	(
		not Data.has_done_dogbase_tutorial or
		(Data.has_done_battlefield_basics_tutorial and not Data.has_done_dogbase_after_battlefield_tutorial)
	):
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		canvas.tree_exited.connect(func(): canvas.queue_free())
	
	if not Data.has_done_battlefield_basics_tutorial:
		%UpgradeButton.disabled = true
		%StoreButton.disabled = true
	
	%ExpeditionButton.pressed.connect(_go_to_map)
	%UpgradeButton.pressed.connect(_go_to_upgrade)
	%StoreButton.pressed.connect(_go_to_store)
	%RankingButton.pressed.connect(_go_to_ranking)
	
func _go_to_map():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file(
		"res://scenes/maps/%s_map/%s_map.tscn" % [Data.selected_chapter_id, Data.selected_chapter_id]
	)

func _go_to_upgrade():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/upgrade/upgrade.tscn")

func _go_to_store():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/store/store.tscn")

@onready var ranking = preload("res://addons/silent_wolf/Scores/Leaderboard.tscn")
func _go_to_ranking():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)	
	get_tree().change_scene_to_packed(ranking)
