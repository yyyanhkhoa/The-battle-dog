extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	Data.tutorial_lost += 1
	
	if Data.tutorial_lost == 1:
		tutorial_dog.start_dialogue("TUTORIAL_LOST_ONCE", TutorialDog.PLACEMENT.RIGHT, false) 
	elif Data.tutorial_lost == 2:  
		tutorial_dog.start_dialogue("TUTORIAL_LOST_TWICE", TutorialDog.PLACEMENT.RIGHT, false) 
	elif Data.tutorial_lost == 3:  
		tutorial_dog.start_dialogue("TUTORIAL_LOST_THRICE", TutorialDog.PLACEMENT.RIGHT, false) 
	elif Data.tutorial_lost == 4:  
		tutorial_dog.start_dialogue("TUTORIAL_KILL", TutorialDog.PLACEMENT.RIGHT, false) 
		await tutorial_dog.dialogue_ended
		# You're dead meat, replace new character
		Data.tutorial_lost = 0
		get_tree().change_scene_to_file("res://scenes/bad_ending/bad_ending.tscn")
