extends CharacterBody2D

var _damage = 100
var _sync_data: Dictionary

func setup(global_position: Vector2, skill_user: Character.Type):
	self.global_position = global_position
	velocity = Vector2(300, 600)
	velocity *= randf_range(1.0, 1.5)
	
	if skill_user == Character.Type.CAT:
		scale.x = -1
		velocity.x = -velocity.x
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
	
	var level := InBattle.get_skill_level('fire_ball', skill_user)
	_damage = _damage + (_damage * 0.1 * level)
		
	_sync_data = { 
		"object_type": P2PObjectSync.ObjectType.SKILL,
		"scene": InBattle.SCENE_FIRE_BALL,
		"instance_id": get_instance_id(),
		"skill_user": skill_user,
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
		
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		set_physics_process(false)
		
		if not InBattle.in_request_mode: 
			die()
		
		var enemy = collision.get_collider() 
		if enemy is Character:
			enemy.take_damage(_damage)	
			var distance: float = enemy.global_position.distance_to(global_position) / 2
			var fx_position: Vector2 = enemy.global_position.move_toward(global_position, distance)
			InBattle.add_hit_effect(fx_position)

func die():
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	$AnimationPlayer.play("die")
	remove_from_group(P2PObjectSync.SYNC_GROUP)
	await get_tree().create_timer(0.7, false).timeout
	queue_free()

func get_p2p_sync_data() -> Dictionary:
	_sync_data["position"] = global_position 
	_sync_data["velocity"] = velocity 
	return _sync_data
	
func p2p_setup(sync_data: Dictionary) -> void:
	setup(sync_data['position'], sync_data['skill_user'])
	velocity = sync_data["velocity"]
	
func p2p_sync(sync_data: Dictionary) -> void:
	global_position = sync_data['position']
	
func p2p_remove() -> void:
	die()
