@tool
class_name AirUnitCat extends BaseCat

@export var movement_radius: int = 500

## move to new target position if after attack is recharged and there is no target to attack [br]
## if set to false, stay at where they are, will not change target when timeout
var change_target_overtime: bool = true

## fairy cat will move around this position
var target_position: Vector2 

var floating_movement_tween: Tween

var _raycast_pos_y: float 

func _ready() -> void:
	super._ready()
	
	
	if Engine.is_editor_hint():
		set_physics_process(false)
		set_process(false)
		return
	
	n_AttackCooldownTimer.timeout.connect(func(): 
		n_RayCast2D.enabled = true
		n_RayCast2D.global_position.y = _raycast_pos_y
		set_physics_process(true)
	)
	
	_raycast_pos_y = InBattle.get_battlefield().get_land().global_position.y - RAYCAST_OFFSET_Y
	
	floating_movement_tween = _create_floating_movement_tween([$CharacterAnimation, $DanmakuHitbox, $CollisionShape2D])
	floating_movement_tween.custom_step(randf_range(0.0, 2.0))
	
	if change_target_overtime == false:
		target_position = global_position
		get_FSM().change_state("IdleState")

func _physics_process(delta: float) -> void:
	n_RayCast2D.global_position.y = _raycast_pos_y
	var fsm: FSM = get_FSM()
	var state: FSMState = fsm.get_current_state()
	var data: Dictionary = fsm.get_current_state_data()
		
	if not n_RayCast2D.is_colliding() or state is AirUnitKnockbackState or (state is AirUnitIdleState and data.has('knockedback')):
		return
		
	if state.has_method("interpolate_movement"):
		fsm.change_state("AttackState", { "interpolate_movement_callback": state.interpolate_movement })
	else:
		fsm.change_state("AttackState")
	
	n_RayCast2D.enabled = false
	n_AttackCooldownTimer.start()
	set_physics_process(false)

## nodes: the nodes that needs tweening (CharacterAnimation, DanmakuHitbox, CollisionShape2D). [br]
## overwrite this method to implement a different floating movement
func _create_floating_movement_tween(nodes: Array[Node2D]) -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_loops().set_parallel()
	
	for node in nodes: 
		tween.tween_property(node, "position:y", 20.0, 0.2).as_relative()

	tween.chain()
	for node in nodes: 
		tween.tween_property(node, "position:y", -20.0, 0.2).as_relative()
	
	return tween
