extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner

func enter(data: Dictionary) -> void:
	tutorial_dog.start_dialogue("TUTORIAL_CAT_TOWER_DAMAGED", TutorialDog.PLACEMENT.LEFT)
	
	tutorial_dog.get_cat_tower().zero_health.connect(_to_victory_state)
	tutorial_dog.get_dog_tower().zero_health.connect(_to_defeat_state)

func _to_victory_state():
	transition.emit("VictoryState")
	
func _to_defeat_state(): 
	transition.emit("DefeatState")

func exit():
	tutorial_dog.get_cat_tower().zero_health.disconnect(_to_victory_state)
	tutorial_dog.get_dog_tower().zero_health.disconnect(_to_defeat_state)
