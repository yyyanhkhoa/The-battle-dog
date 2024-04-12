extends Node

const TOUCH_EPSISLON: float = 2
var VIEWPORT_SIZE := Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

var _delta_timer_pool: DeltaTimerPool  

# called when the state is activated
func _ready():
	_delta_timer_pool = DeltaTimerPool.new()
	add_child(_delta_timer_pool)
	
	SilentWolf.configure({
	"api_key": "goumasbyHC39s9kdTRaOQ8nSC9Xtt8pJ37jLvOSg",
	"game_id": "Thebattledogs",
	"log_level": 1
	})	
	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/main.tscn"
	}) 
	
func is_host_OS_web() -> bool:
	return OS.get_name() == "WEB"

func is_host_OS_web_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")
	
func tr_format(message: StringName) -> String:
	var locale := TranslationServer.get_locale()
	TranslationServer.set_locale('format')
	var format: String = tr(message)
	TranslationServer.set_locale(locale)
	return format 

## wait a certain amount using a shared timers system. the returned timer is pausable by the scene tree [br]
## the signal also contains recover_delta parameter (delta time passed since signal is emited)
func wait(wait_time: float, recover_dela: float = 0.0) -> Signal:
	return _delta_timer_pool.get_shared_timer(wait_time - recover_dela / Engine.time_scale).timeout

## wait a certain amount using a shared timers system. the returned timer is pausable by the scene tree
func wait_cancelable(wait_time: float, recover_dela: float = 0.0) -> WaitToken:
	var timer := _delta_timer_pool.get_shared_timer(wait_time - recover_dela / Engine.time_scale)
	var token := WaitToken.new(timer)
	return token

## return -1 or 1
func rand_sign() -> int:
	return sign(2 * randi_range(0, 1) - 1)

func rand_bool() -> bool:
	return bool(randi_range(0, 1))

func find_closest(node: Node2D, others: Array) -> Node2D:
	var closest: Node2D = null
	var min_distance: float = 1.79769e308
	
	for other in others:
		var distance := node.global_position.distance_squared_to(other.global_position)
		if min_distance > distance:
			min_distance = distance
			closest = other 
			
	return closest
	
func clear_timers() -> void:
	_delta_timer_pool.clear()
