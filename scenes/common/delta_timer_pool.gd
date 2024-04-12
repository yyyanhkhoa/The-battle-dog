class_name DeltaTimerPool extends Node
## a pool of delta timers

var _shared_timers: Dictionary = {}	
var _unused_timers: Array[DeltaTimer] = []
var _timer_ids_to_be_unused: Array[Vector2] = []

## Returns a timer. [br]
## The timer might be shared if they are in the same physics frame and same wait time [br]
## Timers might be created / reused depending if there are enough timers to be shared
func get_shared_timer(wait_time: float) -> DeltaTimer:
	var id := Vector2(Engine.get_physics_frames(), snapped(wait_time, 0.00001))

	var timer: DeltaTimer
	
	if _shared_timers.has(id):
		timer = _shared_timers[id]
	elif not _unused_timers.is_empty():
		timer = _unused_timers.pop_back()
		timer.start(wait_time)
		_shared_timers[id] = timer
	else:
		timer = DeltaTimer.new()
		timer.start(wait_time)
		_shared_timers[id] = timer

	return timer

func _physics_process(delta: float) -> void:
	for id: Vector2 in _shared_timers:
		var timer: DeltaTimer = _shared_timers[id]
		if timer.is_running():
			timer.physics_process(delta)
		elif timer.timeout.get_connections().is_empty() and timer.get_reference_count() <= 2: 
			_timer_ids_to_be_unused.append(id)
			
	for id: Vector2 in _timer_ids_to_be_unused: 
		_unused_timers.append(_shared_timers[id])
		_shared_timers.erase(id)
		
	_timer_ids_to_be_unused.clear()

func clear() -> void:
	_unused_timers.clear()
	_timer_ids_to_be_unused.clear()
