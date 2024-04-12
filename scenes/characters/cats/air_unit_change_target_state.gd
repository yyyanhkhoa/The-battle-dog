class_name ChangeTargetState extends FSMState
## this state will move the chacracter to the target position [br]
## if target_position is Vector2.ZERO (no target_position specified) or if data parameter cotains 'new_target' 
## then a new target position is calculated before moving

@onready var cat: AirUnitCat = owner
@onready var curve: Curve2D = %Path2D.curve

var _passed_delta: float
var _duration: float
var _initial_multiplier: float

func enter(data: Dictionary) -> void:
	## no target position set, set to closest dog found
	if cat.target_position == Vector2.ZERO or data.has('new_target'):
		var closest_dog = Global.find_closest(cat, get_tree().get_nodes_in_group("dogs"))
		
		var battlefield := InBattle.get_battlefield() as BaseBattlefield
		var stage_rect := battlefield.get_stage_rect()
		
		var rand_y = randf_range(stage_rect.position.y + cat.movement_radius, -cat.movement_radius - 300)
		if closest_dog != null:
			cat.target_position = Vector2(closest_dog.global_position.x, rand_y)
		else:
			var stage_width = battlefield.get_stage_width()
			var rand_x = randf_range(max(stage_width * 0.25, BaseBattlefield.TOWER_MARGIN + 1000), stage_width * 0.5)
			
			cat.target_position = Vector2(rand_x, rand_y) 
		
		cat.target_position.x += cat.attack_range
	
	_passed_delta = 0
	
	cat.n_AnimationPlayer.play("move")
	%Path2D.global_position = cat.global_position
	
	var dest_pos = cat.target_position
	dest_pos -= cat.global_position
	
	var up_length := randf_range(dest_pos.length() * 0.03, dest_pos.length() * 0.1)
	
	var offset_angle := dest_pos.angle() - PI * 0.5
	var mid_pos = (dest_pos * 0.5) + Vector2(up_length, 0).rotated(offset_angle)
	
	curve.set_point_position(0, Vector2.ZERO)
	curve.set_point_position(1, mid_pos)
	curve.set_point_position(2, dest_pos)
	
	curve.set_point_in(1, Vector2(up_length * 4, 0).rotated(dest_pos.angle() + PI))
	curve.set_point_out(1, Vector2(up_length * 4, 0).rotated(dest_pos.angle()))
	
	_duration = curve.get_baked_length() / cat.speed
	_initial_multiplier = cat.get_multiplier(Character.MultiplierTypes.SPEED)
	
func physics_update(delta: float) -> void:
	var finished := interpolate_movement(delta)
	
	if finished:
		transition.emit("MoveState")

func interpolate_movement(delta: float) -> bool:
	## cases where the cat's movement speed changes mid way due to being manipulated by external forces e.g: player skills 
	var d := delta * (cat.get_multiplier(Character.MultiplierTypes.SPEED) / _initial_multiplier)
	
	## Ease out transition is a bit slow at the end, this is to speed it up a bit
	if %PathFollow2D.progress_ratio >= 0.7:
		d *= (1 + (%PathFollow2D.progress_ratio - 0.7) * 1.25) ** 2
	
	_passed_delta += d
		
	%PathFollow2D.progress_ratio = Tween.interpolate_value(0.0, 1.0, min(_passed_delta, _duration), _duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	var new_scale_x: int = sign(cat.global_position.x - %PathFollow2D.global_position.x)
	if new_scale_x != 0:
		cat.n_CharacterAnimation.scale.x = new_scale_x
	
	cat.global_position = %PathFollow2D.global_position 
	
	return is_equal_approx(%PathFollow2D.progress_ratio, 1.0)
