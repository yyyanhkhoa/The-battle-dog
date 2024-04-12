extends Node

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/characters/dogs/batter_dog/explosion/batter_dog_explosion.tscn") 

func setup(start_global_position: Vector2, batter_damage: int, dog_level: int, character_type: Character.Type) -> void:
	var explosion_position := start_global_position
	var destination_x: int
	if character_type == Character.Type.DOG:
		explosion_position.x += 200
		destination_x = InBattle.get_battlefield().get_stage_width() + BaseBattlefield.TOWER_MARGIN * 0.5
	else:
		explosion_position.x -= 200
		destination_x = -BaseBattlefield.TOWER_MARGIN * 0.5

	await get_tree().create_timer(0.3, false).timeout
	
	var explosion_num = (2 + dog_level) if dog_level < 10 else 999
	
	if character_type == Character.Type.DOG:
		while explosion_position.x <= destination_x and explosion_num > 0:
			await get_tree().create_timer(0.15, false).timeout
			add_explostion(explosion_position, batter_damage / 10, character_type)
			explosion_position.x += 400
			explosion_num -= 1
	else:
		while explosion_position.x >= destination_x and explosion_num > 0:
			await get_tree().create_timer(0.15, false).timeout
			add_explostion(explosion_position, batter_damage / 10, character_type)
			explosion_position.x -= 400
			explosion_num -= 1
				
	queue_free()
	
func add_explostion(position: Vector2, damage: float, character_type: Character.Type) -> void:
	var explosion: BatterDogExplosion = EXPLOSION_SCENE.instantiate()
	explosion.setup(position, damage, character_type)
	InBattle.get_battlefield().get_effect_space().add_child(explosion)	


