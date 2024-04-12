extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	tutorial_dog.get_cat_tower().boss_appeared.connect(_on_boss_appeared, CONNECT_ONE_SHOT)
	
func _on_boss_appeared():
	await get_tree().create_timer(1.5, false).timeout
	tutorial_dog.start_dialogue("TUTORIAL_BOSS", tutorial_dog.PLACEMENT.LEFT)
	tutorial_dog.dialogue_ended.connect(
		func(): 
			Data.has_done_battlefield_boss_tutorial = true
			Data.save(),
		CONNECT_ONE_SHOT
	)
