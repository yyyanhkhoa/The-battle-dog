extends FSMState
@onready var character: Character = owner
var start_attack := false
var done_attack := false
signal dog_attack
# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.attack_sprite.frame_changed.connect(on_frame_changed)
	character.n_AnimationPlayer.animation_finished.connect(on_animation_finished)
	character.n_AnimationPlayer.play("attack")

func on_frame_changed() -> void:
	if done_attack == false && character.attack_sprite.frame >= character.attack_frame:
		start_attack = true

func physics_update(_delta: float) -> void:
	if start_attack == false:
		return
		
	$Danh.pitch_scale = randf_range(0.85, 1.15)
	$Danh.play()
	dog_attack.emit()
	# custom attack
	if character.custom_attack_area != null:
		for target in character.custom_attack_area.get_overlapping_bodies():
			target.take_damage(character.damage)
			InBattle.add_hit_effect(target.get_effect_global_position())
	
	# single target
	elif character.attack_area_range <= 0:
		# target can be a dog or a dog tower
		var target := character.n_RayCast2D.get_collider()
		if target != null:
			target.take_damage(character.damage)
			InBattle.add_hit_effect(target.get_effect_global_position())

	# area attack
	else:
		var space_state := character.get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var shape_id := PhysicsServer2D.rectangle_shape_create()
		PhysicsServer2D.shape_set_data(shape_id, Vector2(character.attack_area_range / 2, 1))
		
		var shape_query := PhysicsShapeQueryParameters2D.new()
		shape_query.shape_rid = shape_id
		
		if character.character_type == Character.Type.DOG:
			shape_query.collision_mask = 0b10100 # enemy and cat tower
		else:
			shape_query.collision_mask = 0b100010 # enemy and dog tower
		
		var attack_midpoint := character.n_RayCast2D.global_position + character.n_RayCast2D.target_position
		shape_query.transform = Transform2D(0, attack_midpoint) 
		
		var results := space_state.intersect_shape(shape_query, 1000)
		
		# target can be a character or a tower tower
		for result in results:
			result.collider.take_damage(character.damage)
			InBattle.add_hit_effect(result.collider.get_effect_global_position())

	start_attack = false
	done_attack = true

func on_animation_finished(_name):	
	character.n_AttackCooldownTimer.start()
	transition.emit("UserMoveState")
		
# called when the state is deactivated
func exit() -> void:
	start_attack = false
	done_attack = false
	character.attack_sprite.frame_changed.disconnect(on_frame_changed) 
	character.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)


