extends BaseSkill

const FireBall =  preload("res://scenes/skills/fire_ball/ball.tscn")

const X_STEP: int = 400
const Y_STEP: int = 800
const BASE_ROWS: int = 1

func setup(skill_user: Character.Type):
	var battlefield := get_tree().current_scene as BaseBattlefield
	var destination_x_from: int = -battlefield.TOWER_MARGIN + 100
	var destination_x_to: int = battlefield.get_stage_width() - battlefield.TOWER_MARGIN * 2 - 800 
	
	if skill_user == Character.Type.CAT:
		var old_dest_x_from: int = destination_x_from
		destination_x_from = battlefield.get_stage_width() - destination_x_to
		destination_x_to = battlefield.get_stage_width() - old_dest_x_from
		
	var y = -battlefield.get_stage_height() - Y_STEP
	
	var level := InBattle.get_skill_level('fire_ball', skill_user)
	var rows = BASE_ROWS + int(0.5 * level)
	for i in range(rows):
		var x = destination_x_from
		while x < destination_x_to:
			var fire_ball = FireBall.instantiate()
			var rand_x = x + randi_range(-100, 100)
			var rand_y = y + randi_range(-200, 200)
			fire_ball.setup(Vector2(rand_x, rand_y), skill_user)
			
			self.add_child(fire_ball)
			x += X_STEP
		y -= Y_STEP

