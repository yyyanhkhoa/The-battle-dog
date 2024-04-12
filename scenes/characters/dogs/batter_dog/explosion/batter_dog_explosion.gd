class_name BatterDogExplosion extends Node2D

const KNOCKBACK_SCALE: float = 1

var _attack_damage: int
var _sync_data: Dictionary

func setup(global_position: Vector2, attack_damage: int, character_type: Character.Type) -> void:
	_sync_data = {
		"object_type": P2PObjectSync.ObjectType.EFFECT,
		"scene": "res://scenes/characters/dogs/batter_dog/explosion/batter_dog_explosion.tscn",
		"instance_id": get_instance_id(),
		"position": global_position,
		"damage": attack_damage,
		"character_type": character_type
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
		
	self.global_position = global_position
	_attack_damage = attack_damage
	
	if character_type == Character.Type.CAT:
		self.scale.x = -self.scale.x
		$Area2D.set_collision_mask_value(3, false)	
		$Area2D.set_collision_mask_value(2, true)	
		
	$Area2D.body_entered.connect(_on_enemy_entered)

	$AnimationPlayer.animation_finished.connect(func(_anim): queue_free())

func _on_enemy_entered(enemy: Character) -> void:
	InBattle.add_hit_effect(enemy.get_effect_global_position())
	
	if not InBattle.in_request_mode:
		enemy.knockback(KNOCKBACK_SCALE)
		enemy.take_damage(_attack_damage)

func get_p2p_sync_data() -> Dictionary:
	remove_from_group(P2PObjectSync.SYNC_GROUP)
	return _sync_data
	
func p2p_setup(_sync_data: Dictionary) -> void:
	setup(_sync_data['position'], _sync_data['damage'], _sync_data['character_type'])

func p2p_sync(sync_data: Dictionary) -> void:
	return

func p2p_remove() -> void:
	return
