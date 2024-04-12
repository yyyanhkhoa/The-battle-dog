class_name CameraControlButtons extends HBoxContainer
## This class contains buttons to control camera as well as

const SCROLL_WAIT_TIME: float = 0.1

## velocity to move camera when user flick the screen
var flick_velocity: Vector2 = Vector2.ZERO
var _drag_relative: Vector2 = Vector2.ZERO

## screen dragged, used for mocing camera to the dragged position 
signal dragged(relative: Vector2)

func is_move_left_on() -> bool:
	return _is_on($MoveLeft/AnimationPlayer)

func is_move_right_on() -> bool:
	return _is_on($MoveRight/AnimationPlayer)

func is_zoom_out_on() -> bool:
	return _is_on($ZoomOut/AnimationPlayer)

func is_zoom_in_on() -> bool:
	return _is_on($ZoomIn/AnimationPlayer)

func _is_on(anim_player: AnimationPlayer) -> bool:
	return anim_player.current_animation == "on"	

var _scroll_up: bool = false
var _scroll_down: bool = false
func is_scrolling() -> bool: 
	return _scroll_up or _scroll_down

func _ready() -> void:
	$MoveRight.button_down.connect(func(): $MoveRight/AnimationPlayer.play("on"))
	$MoveRight.button_up.connect(func(): $MoveRight/AnimationPlayer.play("off"))
	
	$ZoomOut.button_down.connect(func(): $ZoomOut/AnimationPlayer.play("on"))
	$ZoomOut.button_up.connect(func(): $ZoomOut/AnimationPlayer.play("off"))
	
	$ZoomIn.button_down.connect(func(): $ZoomIn/AnimationPlayer.play("on"))
	$ZoomIn.button_up.connect(func(): $ZoomIn/AnimationPlayer.play("off"))
	
	$Timer.timeout.connect(_stop_scroll)

func _stop_scroll():
	_scroll_up = false
	_scroll_down = false
	$ZoomIn/AnimationPlayer.play("off")
	$ZoomOut/AnimationPlayer.play("off")
	
func is_dragging() -> bool: return not _drag_relative == Vector2.ZERO 
	
func _process(delta: float) -> void:
	var is_controlling: bool = (
		Input.is_action_pressed("ui_left") or $MoveLeft.button_pressed
		or Input.is_action_pressed("ui_right") or $MoveRight.button_pressed
	)
	## prioritize any other user inputs over touch inputs
	if is_controlling:
		flick_velocity = Vector2.ZERO
		_drag_relative = Vector2.ZERO
		
	$MoveLeft/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_left") 
		or $MoveLeft.button_pressed
		or flick_velocity.x < 0 
		or _drag_relative.x > 0
		else "off"
	)
	$MoveRight/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_right") 
		or $MoveRight.button_pressed 
		or flick_velocity.x > 0
		or _drag_relative.x < 0
		else "off"
	)

	$ZoomOut/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_zoomout") 
		or _scroll_down 
		or (_pinch_zoom_scale - _prev_pinch_zoom_scale) < 0
		or $ZoomOut.button_pressed else "off"
	)
	$ZoomIn/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_zoomin") 
		or _scroll_up 
		or (_pinch_zoom_scale - _prev_pinch_zoom_scale) > 0
		or $ZoomIn.button_pressed else "off"
	)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_scroll_up = true
		_scroll_down = false
		$ZoomIn/AnimationPlayer.play("on")
		$ZoomOut/AnimationPlayer.play("off")
		$Timer.wait_time = SCROLL_WAIT_TIME * Engine.time_scale
		$Timer.start()
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_scroll_down = true
		_scroll_up = false
		$ZoomOut/AnimationPlayer.play("on")
		$ZoomIn/AnimationPlayer.play("off")
		$Timer.wait_time = SCROLL_WAIT_TIME * Engine.time_scale
		$Timer.start()

func _unhandled_input(event: InputEvent) -> void:
	_handle_pinch_zoom_input(event)
	
	if is_pinch_zooming():
		_drag_relative = Vector2.ZERO
		swiping = false
	else:
		_handle_swipe_and_drag_input(event)
	
var _touch_positions: Dictionary = {}
var _initial_distance: float = 0
var _pinch_zoom_scale: float = 1
var _prev_pinch_zoom_scale: float = 1

func _handle_pinch_zoom_input(event: InputEvent) -> void:
	## event.index < 2 to ignore 3th fingers onward
	if event is InputEventScreenTouch:
		if event.is_pressed():
			_touch_positions[event.index] = event.position
			
			if _touch_positions.size() > 1:
				_calculate_pinch_zoom_scale()
				
		else:
			_touch_positions.erase(event.index)
			if _touch_positions.size() <= 1:
				_initial_distance = 0
				_pinch_zoom_scale = 1
				_prev_pinch_zoom_scale = 1
			
	if event is InputEventScreenDrag:
		_touch_positions[event.index] = event.position	
		
		if _touch_positions.size() > 1:
			_calculate_pinch_zoom_scale()		

func _calculate_pinch_zoom_scale() -> void:
	var positions = _touch_positions.values() 
	var distance = positions[0].distance_to(positions[1])
	
	if _initial_distance == 0:
		_initial_distance = distance
	
	_prev_pinch_zoom_scale = _pinch_zoom_scale
	_pinch_zoom_scale = distance / _initial_distance

func is_pinch_zooming() -> bool: 
	return _touch_positions.size() > 1

func get_pinch_zoom_scale() -> float:
	return _pinch_zoom_scale

## mobile camera control
var swiping = false
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []

func _handle_swipe_and_drag_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.pressed:
			swiping = true
			flick_velocity = Vector2.ZERO
			swipe_mouse_start = ev.position
			swipe_mouse_times = [Time.get_ticks_msec()]
			swipe_mouse_positions = [swipe_mouse_start]
		else:
			swipe_mouse_times.append(Time.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source = position
			var idx = swipe_mouse_times.size() - 1
			var now = Time.get_ticks_msec()
			var cutoff = now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start = swipe_mouse_positions[idx]
			var flick_dur = min(0.3, (ev.position - flick_start).length() / 500)
			if flick_dur > 0.0:
				var delta = flick_start - ev.position 
				var target = source + delta * flick_dur * 25.0
				flick_velocity = (target - position) / flick_dur
			else:
				flick_velocity = Vector2.ZERO
			
			swiping = false
			_drag_relative = Vector2.ZERO
				
	elif swiping and ev is InputEventMouseMotion:
		_drag_relative = ev.relative
		dragged.emit(_drag_relative)
		swipe_mouse_times.append(Time.get_ticks_msec())
		swipe_mouse_positions.append(ev.position)
		
		## stop button from active if drag stopped
		await get_tree().create_timer(0.1 * Engine.time_scale, false).timeout
		if _drag_relative == ev.relative:
			_drag_relative = Vector2.ZERO
