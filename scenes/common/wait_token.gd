class_name WaitToken extends CancellationToken

var timer: DeltaTimer

func _init(timer: DeltaTimer) -> void:
	self.timer = timer

## returns the timeout signal
func wait() -> Signal: 
	return timer.timeout

