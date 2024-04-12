class_name DanmakuPattern extends RefCounted

signal finished

## number of points inside the pattern
var bullet_num: int = 0

var _starting: bool = false
func is_starting() -> bool: return _starting

var _callback: Callable
var _sum_delta: float
var _bullet_count: float
var _callback_interval: float
var _cancellation_token: CancellationToken

func start(duration: float, callback: Callable, cancellation_token: CancellationToken = null) -> Signal:
	_starting = true
	_bullet_count = 0
	_callback = callback
	_cancellation_token = cancellation_token
	
	if not is_zero_approx(duration):
		_callback_interval = duration / bullet_num
		_sum_delta = _callback_interval 
	else:
		while _bullet_count < bullet_num: 
			_handle_callback(0.0, _bullet_count, _callback)
			_bullet_count += 1

		finished.emit()
		_starting = false
		_callback = Callable()
			
	return finished

func _handle_callback(recover_delta: float, bullet_index: int, callback: Callable) -> void:
	push_error("ERROR: _handle_callback(recover_delta: float, bullet_index: int, callback: Callable) not implemented")
	
func _process(delta: float) -> void:
	if _cancellation_token != null and _cancellation_token.is_canceled():
		finished.emit()
		_starting = false
		_callback = Callable()
		return
	
	_sum_delta += delta
	while is_equal_approx(_sum_delta, _callback_interval) or _sum_delta > _callback_interval:
		_sum_delta -= _callback_interval
		_handle_callback(_sum_delta, _bullet_count, _callback)
		_bullet_count += 1
		
		if _bullet_count >= bullet_num:
			finished.emit()
			_starting = false
			_callback = Callable()
			return
