class_name BattlefieldTutorialDog extends TutorialDog

var _cat_tower: CatTower 
func get_cat_tower() -> CatTower:
	return _cat_tower
	
var _dog_tower: DogTower
func get_dog_tower() -> DogTower:
	return _dog_tower
	
var	_camera: Camera2D
func get_camera() -> Camera2D:
	return _camera
	
var _gui: BattleGUI
func get_battlefield_gui() -> BattleGUI:
	return _gui
	
var _game_speed_button: GameSpeedButton

## setup TutorialDog
func setup(cat_tower: CatTower, dog_tower: DogTower, camera: Camera2D, gui: BattleGUI):
	_cat_tower = cat_tower
	_dog_tower = dog_tower
	_camera = camera
	_gui = gui
	_game_speed_button = _gui.game_speed_button
	
	
func start_dialogue(dialogue_code: String, jump_in_direction: PLACEMENT, pause_game: bool = true) -> void:
	if _game_speed_button != null and _game_speed_button.is_actived():
		_game_speed_button.toggle_game_speed()
		## in case where game_speed_button is freed
		_game_speed_button.button_toggled.connect(_start.bind(dialogue_code, jump_in_direction, pause_game))
		_game_speed_button.tree_exiting.connect(_start.bind(dialogue_code, jump_in_direction, pause_game))
	else:
		super.start_dialogue(dialogue_code, jump_in_direction, pause_game)

func _start(dialogue_code: String, jump_in_direction: PLACEMENT, pause_game: bool):
	_game_speed_button.button_toggled.disconnect(_start.bind(dialogue_code, jump_in_direction, pause_game))
	_game_speed_button.tree_exiting.disconnect(_start.bind(dialogue_code, jump_in_direction, pause_game))
	super.start_dialogue(dialogue_code, jump_in_direction, pause_game)

func end_dialogue() -> void:
	await super.end_dialogue()
	
	if _game_speed_button != null and _game_speed_button.is_actived(): 
		_game_speed_button.toggle_game_speed()
