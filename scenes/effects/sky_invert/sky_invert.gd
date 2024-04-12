class_name FXSkyInvert extends ColorRect

var _origin: Vector2
var _camera: Camera2D
@onready var _shader := material as ShaderMaterial

func _ready() -> void:
	set_process(false)

# these variables need to be set before node is ready
var subtract := Color.BLACK
var add := Color.BLACK
var multiply := Color.WHITE
var difference := Color.BLACK
var exclusion := Color.BLACK
var hue_shift: float = 0
var invert: float = 1.0
var sky_movement_scale: float = 1.0

const BASE_DURATION = 0.75

func setup(
		camera: Camera2D,
		sky: BattlefieldSky,
		origin: Vector2,
) -> void:
	
	_origin = origin
	_camera = camera
	
	## this one is used for the sky only
	var sky_invert_shader := ColorRect.new()
	sky_invert_shader.material = material
	sky_invert_shader.size = sky.size + Vector2(0, 100)
	sky_invert_shader.global_position = sky.global_position
	sky_invert_shader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.add_sibling(sky_invert_shader)
	
	await ready
	set_process(true)
	
	size = Global.VIEWPORT_SIZE
	var stage_rect := InBattle.get_battlefield().get_stage_rect() as Rect2
	
	## pick the longest side that reaches the end of the sky (of x axis)
	var longest_distance: float = max(_origin.x - stage_rect.position.x, stage_rect.position.x + stage_rect.size.x - _origin.x)
	
	## scale the circle so that it will grow until it covers the entire sky.
	## with the camera's min zoom as the default zoom (1.0) in the shader.
	var circle_scale: float = (longest_distance / (size.x * 0.5)) * _camera.min_zoom.x

	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_method(func(value: float): _shader.set_shader_parameter('circle_size', value),
		0.0, 1.05 * circle_scale, BASE_DURATION * circle_scale
	)
	
	if not is_zero_approx(hue_shift):
		tween.tween_method(func(value: float): _shader.set_shader_parameter('hue_shift', value),
			0.0, hue_shift, BASE_DURATION * circle_scale
		)
	
	if not is_zero_approx(invert):
		tween.tween_method(func(value: float): _shader.set_shader_parameter('invert', value),
			0.0, invert, BASE_DURATION * circle_scale
		)
		
	if subtract != Color.BLACK:
		tween.tween_method(func(value: Color): _shader.set_shader_parameter('subtract', value),
			Color.TRANSPARENT, subtract, BASE_DURATION * circle_scale
		)
		
	if add != Color.BLACK:
		tween.tween_method(func(value: Color): _shader.set_shader_parameter('add', value),
			Color.TRANSPARENT, add, BASE_DURATION * circle_scale
		)
		
	if multiply != Color.WHITE:
		tween.tween_method(func(value: Color): _shader.set_shader_parameter('multiply', value),
			Color.TRANSPARENT, multiply, BASE_DURATION * circle_scale
		)
	
	if difference != Color.BLACK:
		tween.tween_method(func(value: Color): _shader.set_shader_parameter('difference', value),
			Color.TRANSPARENT, difference, BASE_DURATION * circle_scale
		)
	
	if exclusion != Color.BLACK:
		tween.tween_method(func(value: Color): _shader.set_shader_parameter('exclusion', value),
			Color.TRANSPARENT, exclusion, BASE_DURATION * circle_scale
		)

	if not is_equal_approx(sky_movement_scale, 1.0):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		sky.material = sky.material.duplicate()
	
		var sky_shader = sky.material as ShaderMaterial
		var initial_sky_speed_scale = sky_shader.get_shader_parameter('noise_speed_scale')
		var final_sky_speed_scale = initial_sky_speed_scale * sky_movement_scale
		tween.tween_method(func(value: float): sky_shader.set_shader_parameter('noise_speed_scale', value),
			initial_sky_speed_scale, final_sky_speed_scale * 2.0, BASE_DURATION * 0.5 * circle_scale
		)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_method(func(value: float): sky_shader.set_shader_parameter('noise_speed_scale', value),
			final_sky_speed_scale * 2.0, final_sky_speed_scale, BASE_DURATION * 0.5 * circle_scale
		)
	
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 15.0)
	tween.tween_callback(func(): 
		z_index = sky_invert_shader.z_index
		modulate.a = 1.0
		sky_invert_shader.visible = false
		sky_invert_shader.queue_free()
		InBattle.get_battlefield().move_child(self, sky.get_index())
	)

func _process(delta: float) -> void:
	global_position = _camera.get_screen_center_position() - pivot_offset
	_shader.set_shader_parameter('position', Vector2(0.5, 0.5) - ((_camera.get_screen_center_position() - _origin) / (size / _camera.zoom.x)))
	
	## let the camera's min zoom as the default zoom (1.0) in the shader
	_shader.set_shader_parameter('zoom', _camera.zoom.x / _camera.min_zoom.x)
	scale = Vector2.ONE / _camera.zoom
