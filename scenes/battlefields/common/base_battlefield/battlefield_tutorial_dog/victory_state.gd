extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	tutorial_dog.start_dialogue("TUTORIAL_WON", TutorialDog.PLACEMENT.RIGHT, false)
	Data.has_done_battlefield_basics_tutorial = true
	Data.save()
