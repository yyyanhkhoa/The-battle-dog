extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	await get_tree().create_timer(9.0, false).timeout
	tutorial_dog.start_dialogue("TUTORIAL_FINAL_BOSS", tutorial_dog.PLACEMENT.RIGHT)
	tutorial_dog.dialogue_ended.connect(
		func(): 
			Data.has_done_battlefield_final_boss_tutorial = true
			Data.save(),
		CONNECT_ONE_SHOT
	)
