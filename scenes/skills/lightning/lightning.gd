extends BaseSkill

const LIGHTNING_SPACE_X: int = 500
const LIGHTNING_ROW_OFFSET_X: int = 250

const Lightning: PackedScene = preload("res://scenes/skills/lightning/light.tscn")

func setup(skill_user: Character.Type) -> void:
	var battlefield := get_tree().current_scene as BaseBattlefield
	var level = InBattle.get_skill_level("lightning", skill_user)
	var direction: int = 1 if skill_user == Character.Type.DOG else -1 
	
	var left_x = battlefield.TOWER_MARGIN
	var right_x = battlefield.get_stage_width() - battlefield.TOWER_MARGIN
	for i in range(level):
		drop_lightnings(left_x, right_x, direction, skill_user)
		var should_offset: int = 1 if (i % 2 == 0) else -1
		var offset: int = LIGHTNING_ROW_OFFSET_X * should_offset * direction
		left_x += offset
		right_x += offset
		await get_tree().create_timer(0.25, false).timeout		
		
	queue_free()
	
func drop_lightnings(left_x: int, right_x: int, direction: int, skill_user: Character.Type) -> void:
	var stage_height := InBattle.get_battlefield().get_stage_height()
	if direction == 1:
		var x := left_x
		while x <= right_x:
			add_lightning(Vector2(x, -stage_height), skill_user)
			x += LIGHTNING_SPACE_X
			await get_tree().create_timer(0.05, false).timeout
	else:
		var x := right_x
		while x >= left_x:
			add_lightning(Vector2(x, -stage_height), skill_user)
			x -= LIGHTNING_SPACE_X
			await get_tree().create_timer(0.05, false).timeout		

func add_lightning(global_position: Vector2, skill_user: Character.Type):
	var item = Lightning.instantiate()
	InBattle.get_battlefield().add_child(item)
	item.setup(global_position, skill_user)
