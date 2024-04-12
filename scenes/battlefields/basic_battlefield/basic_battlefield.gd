class_name BasicBattlefield extends TwoTowersBattlefield

var TutorialDogScene: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var _tutorial_dog: BattlefieldTutorialDog = null
var start_time: float

## get theme of the battlefield
func get_theme() -> String: return _stage_data['theme']

func _ready() -> void:
	super()
	if (
		not Data.has_done_battlefield_basics_tutorial 
		or not Data.has_done_battlefield_boss_tutorial
		or not Data.has_done_battlefield_final_boss_tutorial
		or not Data.has_done_battlefield_rush
	):
		_tutorial_dog = TutorialDogScene.instantiate()
		_tutorial_dog.setup(cat_tower, dog_tower, $Camera2D, $Gui)
		$Gui.add_child(_tutorial_dog)
		
	start_time = Time.get_ticks_msec()

func _clean_up() -> void:
	super()
	if _tutorial_dog != null:
		_move_tutorial_dog()

## move the tutorial dog outside of gui
func _move_tutorial_dog():
	var canvas_layer: = CanvasLayer.new()
	canvas_layer.layer = 2
	add_child(canvas_layer)
	_tutorial_dog.reparent(canvas_layer)

func _win() -> void:
	super()
	
	var duration = (Time.get_ticks_msec() - start_time) / 1000 
	if (Data.use_sw_data == true) and (Data.selected_stage == Data.chapter_last_stage):
		Data.victory_count += 1 
		SilentWolf.sw_save_high_scores(Data.save_data["user_name"], "victory_count",1)
		SilentWolf.sw_save_score_time(Data.save_data["user_name"], duration, "fastest_time")
		Data.save()
