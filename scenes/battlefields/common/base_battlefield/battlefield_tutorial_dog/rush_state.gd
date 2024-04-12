extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	await get_tree().create_timer(1, false).timeout
	tutorial_dog.start_dialogue("TUTORIAL_RUSH", tutorial_dog.PLACEMENT.RIGHT)
	tutorial_dog.dialogue_ended.connect(
		func(): 
			Data.has_done_battlefield_rush = true
			Data.save(),
		CONNECT_ONE_SHOT
	)
