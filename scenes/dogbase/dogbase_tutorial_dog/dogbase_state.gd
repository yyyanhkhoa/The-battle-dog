extends FSMState

@onready var tutorial_dog: TutorialDog = owner

func enter(data: Dictionary) -> void:
	tutorial_dog.start_dialogue("TUTORIAL_DOGBASE", TutorialDog.PLACEMENT.RIGHT)
	tutorial_dog.dialogue_ended.connect(func(): 
		owner.queue_free()
		Data.has_done_dogbase_tutorial = true
		Data.save()
	)
