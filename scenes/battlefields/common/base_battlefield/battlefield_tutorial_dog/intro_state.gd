extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner
var gui: BattleGUI 
var cat_tower: CatTower
var dog_tower: DogTower

# called when the state is activated
func enter(data: Dictionary) -> void:
	cat_tower = tutorial_dog.get_cat_tower() 
	dog_tower = tutorial_dog.get_dog_tower()
	
	if Data.has_done_battlefield_basics_tutorial:
		if not Data.has_done_battlefield_boss_tutorial:
			transition.emit("BossAppearedState")
			
		if (
			not Data.has_done_battlefield_rush 
			and Data.selected_stage == 5
		):
			transition.emit("RushState")
			
			
		if (
			not Data.has_done_battlefield_final_boss_tutorial 
			and Data.selected_stage == 12
		):
			transition.emit("FinalBossState")
		
		return
		
	# tutorial basics section	
	# skip parts of tutorial
	if Data.tutorial_lost == 1:
		cat_tower.damage_taken.connect(_to_cat_tower_damage_taken_state)
		dog_tower.zero_health.connect(_to_defeat_state)
		return
		
	await get_tree().create_timer(2.0, false).timeout
	
	gui = tutorial_dog.get_battlefield_gui()
	tutorial_dog.dialogue_line_changed.connect(_on_next_line)
	tutorial_dog.start_dialogue("TUTORIAL_INTRO", tutorial_dog.PLACEMENT.RIGHT)
	tutorial_dog.dialogue_ended.connect(func(): transition.emit("DogSpawnState"), CONNECT_ONE_SHOT)
	
	# disable cat from spawning until a certain part of the tutorial is completed 
	tutorial_dog.get_cat_tower().process_mode = PROCESS_MODE_DISABLED

func _to_cat_tower_damage_taken_state():
	transition.emit("CatTowerDamageTakenState")
	
func _to_defeat_state(): 
	transition.emit("DefeatState")

func exit():
	if Data.tutorial_lost == 1:
		cat_tower.damage_taken.disconnect(_to_cat_tower_damage_taken_state)
		dog_tower.zero_health.disconnect(_to_defeat_state)

var action_index: int = 0
var actions: Array[Dictionary] = [
	{ 
		"index": 4, 
		"enter": ( func(): 
			gui.spawn_buttons.first_row.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
			gui.spawn_buttons.second_row.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
			),
		"exit": ( func(): 
			gui.spawn_buttons.first_row.z_index = 0
			gui.spawn_buttons.second_row.z_index = 0
			)
	},
	{ 
		"index": 5, 
		"enter": func(): gui.spawn_buttons.first_row.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.spawn_buttons.first_row.z_index = 0
	},
	{ 
		"index": 6, 
		"enter": func(): gui.money_label.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.money_label.z_index = 0
	},
]

func _on_next_line(index: int) -> void:
	if action_index == actions.size():
		actions[action_index - 1]["exit"].call()
		tutorial_dog.dialogue_line_changed.disconnect(_on_next_line) 
		return
	
	if index != actions[action_index]["index"]:
		return

	if action_index > 0:
		actions[action_index - 1]["exit"].call()
	
	actions[action_index]["enter"].call()
	action_index += 1
