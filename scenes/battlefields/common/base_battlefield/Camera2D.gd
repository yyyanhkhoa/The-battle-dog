extends Camera2D

const ZOOM_SPEED: float = 2
const MOVE_SPEED: int = 2500
const MAX_ZOOM := Vector2.ONE
const LAND_HEIGHT: int = 283
var min_zoom: Vector2

var _camera_control_buttons: CameraControlButtons
var viewport_size: Vector2
var half_viewport_size: Vector2

## https://github.com/godotengine/godot-proposals/issues/685
var _last_center_x: float = 0
var _last_pos_x: float = 0

var _zoom_value_before_pinch: Vector2 = Vector2.ZERO

var _mouse_pos: Vector2

func setup(camera_control_buttons: CameraControlButtons, stage_rect: Rect2):
	_camera_control_buttons = camera_control_buttons
	_camera_control_buttons.dragged.connect(_handle_screen_drag)

	viewport_size = Global.VIEWPORT_SIZE
	half_viewport_size =  viewport_size / 2

	limit_left = stage_rect.position.x
	limit_right = stage_rect.position.x + stage_rect.size.x
	limit_top = stage_rect.position.y
	limit_bottom = stage_rect.position.y + stage_rect.size.y
	
	var min_zoom_scale:float = max(float(viewport_size.x) / stage_rect.size.x, float(viewport_size.y) / stage_rect.size.y) 
	min_zoom = Vector2(min_zoom_scale, min_zoom_scale) 
	zoom = Vector2(min_zoom_scale, min_zoom_scale)
	
	position = Vector2(0, -half_viewport_size.y)

func _process(delta: float) -> void:
	position = get_screen_center_position()
	
	# stop flick velocity if camera has reach it's limit position
	if (
		not is_equal_approx(position.x, _last_pos_x) 
		and is_equal_approx(position.x, _last_center_x)
	):
		_camera_control_buttons.flick_velocity = Vector2.ZERO

	if not _camera_control_buttons.is_dragging():
		if not _camera_control_buttons.flick_velocity.is_zero_approx():
			position = position + _camera_control_buttons.flick_velocity * (delta / Engine.time_scale)
		else:
			var left := int(_camera_control_buttons.is_move_left_on())
			var right := int(_camera_control_buttons.is_move_right_on())
			var direction := right - left
			position.x = position.x + MOVE_SPEED * direction * (delta / Engine.time_scale)
		
	_last_center_x = get_screen_center_position().x
	_last_pos_x = position.x
	
	if _camera_control_buttons.is_pinch_zooming():
		zoom = _zoom_value_before_pinch * _camera_control_buttons.get_pinch_zoom_scale()
		zoom = clamp(zoom, min_zoom, MAX_ZOOM)
	else:	
		var zoom_in := int(_camera_control_buttons.is_zoom_in_on())
		var zoom_out := int(_camera_control_buttons.is_zoom_out_on())
		var zoom_dir := zoom_in - zoom_out
		if zoom_dir != 0:
			handle_zoom(zoom_dir, delta)
			
		_zoom_value_before_pinch = zoom
		
	force_update_scroll()

## https://ask.godotengine.org/25983/camera2d-zoom-position-towards-the-mouse
## with modifications
func handle_zoom(direction: int, delta: float):
	var prev_zoom := zoom
	zoom += zoom * ZOOM_SPEED * (delta / Engine.time_scale) * direction
	zoom = zoom.clamp(min_zoom, MAX_ZOOM)
	
	position = position  + (_mouse_pos - half_viewport_size) * (
		(Vector2.ONE/prev_zoom) - (Vector2.ONE/zoom)
	)
	
	if not _camera_control_buttons.is_scrolling():
		position.y = limit_bottom - half_viewport_size.y
	
func allow_user_input_camera_movement(state: bool) -> void:
	set_process(state)

func _handle_screen_drag(value: Vector2) -> void:
	position -= value
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_pos = event.position
