@tool
extends FSMState
## Default character attack state, toggle these property in the animation player to trigger a certain action

@onready var character: Character = owner

## indicate attack has started (custom area attack need to set this value when start attacking)
@export var start_attack := false

## indicate attack has been done (custom area attack need to set this value when done attacking)
@export var done_attack := false

## indicate wether attack_sfx should be played
@export var play_attack_sfx := false:
	set(value):
		play_attack_sfx = value
		if play_attack_sfx:
			AudioPlayer.play_in_battle_sfx(character.attack_sfx, 1.0, true)

func _validate_property(property: Dictionary) -> void:
	if character == null:
		return
	
	if property.name in ["start_attack", "done_attack"] and character.attack_type != Character.AttackType.CUSTOM_AREA:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "play_attack_sfx" and character.attack_sfx == null:
		property.usage = PROPERTY_USAGE_NO_EDITOR

var cutom_area_affected: Dictionary = {}

# called when the state is activated
func enter(_data: Dictionary) -> void:
	start_attack = false
	done_attack = false
	
	if character.custom_attack_area == null: 
		character.attack_sprite.frame_changed.connect(_check_attack_has_start)
	
	character.n_AnimationPlayer.animation_finished.connect(on_animation_finished)
	character.n_AnimationPlayer.play("attack")
	
	if character.custom_attack_area != null:
		character.custom_attack_area.monitoring = true
		character.custom_attack_area.collision_mask = character.n_RayCast2D.collision_mask

## handling non-custom area attack start 
func _check_attack_has_start() -> void:
	if done_attack == false && character.attack_sprite.frame >= character.attack_frame:
		start_attack = true

func physics_update(_delta: float) -> void:
	if start_attack == false:
		return
	
	var random_effect_offset = Vector2(randi_range(-20, 20), randi_range(-20, 20))
	
	if character.attack_type == Character.AttackType.CUSTOM_AREA:
		for target in character.custom_attack_area.get_overlapping_bodies():
			if not cutom_area_affected.has(target):
				target.take_damage(character.damage)
				InBattle.add_hit_effect(target.get_effect_global_position() + random_effect_offset)
				
			cutom_area_affected[target] = true
		
		if not cutom_area_affected.is_empty() and character.attack_hit_sfx != null:
			AudioPlayer.play_in_battle_sfx(character.attack_hit_sfx, AudioPlayer.get_random_pitch_scale())
		
	elif character.attack_type == Character.AttackType.SINGLE:
		# target can be a dog or a dog tower
		var target := character.n_RayCast2D.get_collider()
		if target != null:
			target.take_damage(character.damage)
			InBattle.add_hit_effect(target.get_effect_global_position() + random_effect_offset)
			
			if character.attack_hit_sfx != null:
				AudioPlayer.play_in_battle_sfx(character.attack_hit_sfx, AudioPlayer.get_random_pitch_scale())
		
		start_attack = false
		done_attack = true
		
	elif character.attack_type == Character.AttackType.AREA:
		var space_state := character.get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var shape_id := PhysicsServer2D.rectangle_shape_create()
		PhysicsServer2D.shape_set_data(shape_id, Vector2(character.attack_area_range / 2, 1))
		
		var shape_query := PhysicsShapeQueryParameters2D.new()
		shape_query.shape_rid = shape_id
		shape_query.collision_mask = character.n_RayCast2D.collision_mask
		
		var attack_midpoint := character.n_RayCast2D.global_position + character.n_RayCast2D.target_position
		shape_query.transform = Transform2D(0, attack_midpoint) 
		
		var results := space_state.intersect_shape(shape_query, 1000)
		
		# target can be a character or a tower tower
		for result in results:
			result.collider.take_damage(character.damage)
			InBattle.add_hit_effect(result.collider.get_effect_global_position() + random_effect_offset)
			
		if not results.is_empty() and character.attack_hit_sfx != null:
			AudioPlayer.play_in_battle_sfx(character.attack_hit_sfx, AudioPlayer.get_random_pitch_scale())

		start_attack = false
		done_attack = true

func on_animation_finished(_name):	
	character.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
		
# called when the state is deactivated
func exit() -> void:
	cutom_area_affected.clear()
	character.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)
	if character.custom_attack_area == null: 
		character.attack_sprite.frame_changed.disconnect(_check_attack_has_start) 
	else:
		character.custom_attack_area.monitoring = false 
