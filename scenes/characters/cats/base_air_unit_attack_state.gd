class_name BaseAirUnitAttackState extends FSMState
## Abstract Air unit character attack state, overwrite method to implement the attack and handle transition

## continue previous movement, if false, previous_movement_finished will be set to true
@export var continue_previous_movement: bool = true

## this will be called if previous state's movement interpolation is unfinished and needed to be called now
var previous_movement_callback: Callable

var previous_movement_finished: bool = false

func enter(data: Dictionary) -> void:
	var cat := owner as AirUnitCat
	
	InBattle.get_danmaku_space().destroy_bullets_of(owner)
	previous_movement_callback = data.get('previous_movement_callback', Callable())
	
	if not continue_previous_movement or not previous_movement_callback.is_valid():
		previous_movement_finished = true 
		
## overwrite this method to implement the attack 
func physics_update(delta: float) -> void:
	if previous_movement_finished:
		return 
		
	previous_movement_finished = previous_movement_callback.call(delta)
