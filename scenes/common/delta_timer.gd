class_name DeltaTimer extends RefCounted
## Timer but uses delta inside of physics process to count down

## recover_timer: delta time that exceeded time_left 
signal timeout(recover_timer: float);

var time_left: float;
var wait_time: float;

var _running: bool = false
func is_running() -> bool: return _running

func start(wait_time: float):
	self.wait_time = wait_time
	time_left = wait_time
	_running = true

func physics_process(delta: float) -> void:
	time_left -= delta
	
	if is_zero_approx(time_left) or time_left < 0.0:
		var recover_delta: float = abs(time_left)
		time_left = 0.0
		_running = false
		timeout.emit(recover_delta)
