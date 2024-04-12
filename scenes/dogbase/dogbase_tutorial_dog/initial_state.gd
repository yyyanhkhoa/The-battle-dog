extends FSMState

@onready var tutorial_dog: TutorialDog = owner

func enter(data: Dictionary) -> void:
	if not Data.has_done_dogbase_tutorial:
		transition.emit("DogbaseState")
	elif Data.has_done_battlefield_basics_tutorial and not Data.has_done_dogbase_after_battlefield_tutorial:
		transition.emit("DogbaseAfterBattlefieldState")
	else:
		tutorial_dog.queue_free()

