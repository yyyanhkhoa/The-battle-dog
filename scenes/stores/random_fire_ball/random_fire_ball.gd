extends Node2D

const FireBall =  preload("res://scenes/skills/fire_ball/ball.tscn")

const X_STEP: int = 400
const Y_STEP: int = 800
const BASE_ROWS: int = 1
var dog_tower 
var skill_user = Character.Type.DOG
func store_setup(_dog_tower: DogTower,  player_data: BaseBattlefieldPlayerData):
	Data.store["random_fire_ball"].amount -= 1
	dog_tower = _dog_tower
	var battlefield := get_tree().current_scene as BaseBattlefield
	var destination_x_from: int = -battlefield.TOWER_MARGIN + 100
	var destination_x_to: int = battlefield.get_stage_width() - battlefield.TOWER_MARGIN * 2 - 800
	
	var y = -battlefield.get_stage_height() - Y_STEP
	
	var level := InBattle.get_skill_level('fire_ball', skill_user)
	if (level <= 1) :
		level = 2
	
	for i in range(1000):
		var x = destination_x_from
		var fire_ball = FireBall.instantiate()
		var rand_x = randi_range(destination_x_from - 100, destination_x_to)
		var rand_y = y + randi_range(-200, 200)
		fire_ball.setup(Vector2(rand_x, rand_y), skill_user)
		
		self.add_child(fire_ball)
		await get_tree().create_timer(3).timeout
	
#	var posti = InBattle.STAGE_WIDTH_MARGIN 
#	for i in range(0,10):
#		var item = FireBall.instantiate()
#		randomize()	 
#		var random_value = randi_range(posti-100 , InBattle.battlefield_data["stage_width"] - posti - 1100)
#		var random_value_y = randi_range(-800,-900)
#		item.global_position = Vector2(random_value, random_value_y) 		
#		self.add_child(item)
#		await get_tree().create_timer(1).timeout
