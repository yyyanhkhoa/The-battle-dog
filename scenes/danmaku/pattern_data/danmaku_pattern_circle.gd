class_name DanmakuPatternCircle extends DanmakuPattern
## Circluar pattern [br] 
## callback args: position, angle (in radiant), recover_delta, index

const TwoPI: float = 2.0 * PI

var origin: Vector2 = Vector2.ZERO
var radius: float = 0.0

## or if number of bullets is not known, you can use step instead (the density of this bullet)
var step: float:
	get: return (TwoPI * end_point - TwoPI * start_point) / bullet_num
	set(value): bullet_num = int((TwoPI * end_point - TwoPI * start_point) / value)

## in radiant
var angle_offset: float = 0.0
## the stating part of the circle pattern
var start_point: float = 0.0
## the ending of the circle pattern
var end_point: float = 1.0

var clockwise_direction: bool = true

func _handle_callback(recover_delta: float, index: int, callback: Callable) -> void:
	var start_angle = angle_offset + start_point * step
	var angle: float = start_angle + index * step * (int(clockwise_direction) * 2 - 1)
	var offset := Vector2(radius, 0).rotated(angle)

	if callback.is_valid():
		callback.call(
			origin + offset, angle, recover_delta, index 
		)
