extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner
var cat_tower: CatTower
var dog_tower: DogTower

func enter(data: Dictionary) -> void:
	var camera := tutorial_dog.get_camera()
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	camera.allow_user_input_camera_movement(false)
	
	cat_tower = tutorial_dog.get_cat_tower() 
	dog_tower = tutorial_dog.get_dog_tower()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_parallel()

	tween.tween_property(camera, "position", cat_tower.position, 1.5)
	
	await tween.finished
	
	## enbale cat spawning
	cat_tower.process_mode = PROCESS_MODE_INHERIT
	var cat := cat_tower.spawn("cat")
		
	await get_tree().create_timer(1.0, false).timeout
		
	tutorial_dog.start_dialogue("TUTORIAL_CAT_SPAWN", TutorialDog.PLACEMENT.LEFT)
	tutorial_dog.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
	
func _on_dialogue_ended():
	var camera := tutorial_dog.get_camera()
	camera.process_mode = Node.PROCESS_MODE_INHERIT
	camera.allow_user_input_camera_movement(true)
	
	cat_tower.damage_taken.connect(_to_cat_tower_damage_taken_state)
	dog_tower.zero_health.connect(_to_defeat_state)

func exit():
	cat_tower.damage_taken.disconnect(_to_cat_tower_damage_taken_state)
	dog_tower.zero_health.disconnect(_to_defeat_state)

func _to_cat_tower_damage_taken_state():
	transition.emit("CatTowerDamageTakenState")
	
func _to_defeat_state(): 
	transition.emit("DefeatState")
