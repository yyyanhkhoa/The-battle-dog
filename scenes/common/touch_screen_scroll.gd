extends ScrollContainer
## Allows you to scroll a scroll container by dragging.
## Includes momentum.

var swiping = false
var swipe_start
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []

var drag_distance := Vector2.ZERO

func _ready() -> void:
	set_process_input(visible)
	visibility_changed.connect(func():
		set_process_input(visible)
)

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			swiping = true
			swipe_start = Vector2(get_h_scroll(), get_v_scroll())
			swipe_mouse_start = ev.position
			swipe_mouse_times = [Time.get_ticks_msec()]
			swipe_mouse_positions = [swipe_mouse_start]
		else:
			swipe_mouse_times.append(Time.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source = Vector2(get_h_scroll(), get_v_scroll())
			var idx = swipe_mouse_times.size() - 1
			var now = Time.get_ticks_msec()
			var cutoff = now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start = swipe_mouse_positions[idx]
			var flick_dur = min(0.3, (ev.position - flick_start).length() / 500)
			if flick_dur > 0.0:
				var tween = create_tween()
				var delta = ev.position - flick_start
				var target = source - delta * flick_dur * 15.0
				tween.set_trans(Tween.TRANS_LINEAR)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_method(set_h_scroll, source.x, target.x, flick_dur)
				tween.tween_method(set_v_scroll, source.y, target.y, flick_dur)
				tween.play()
			
			## consume the input to avoid children from reacting if has been scrolled
			if drag_distance.length() > Global.TOUCH_EPSISLON:
				get_viewport().set_input_as_handled()
				
			swiping = false
			drag_distance = Vector2.ZERO
				
	elif swiping and ev is InputEventMouseMotion:
		drag_distance += ev.relative.abs()
		var delta = ev.position - swipe_mouse_start
		set_h_scroll(swipe_start.x - delta.x)
		set_v_scroll(swipe_start.y - delta.y)
		swipe_mouse_times.append(Time.get_ticks_msec())
		swipe_mouse_positions.append(ev.position)
		

