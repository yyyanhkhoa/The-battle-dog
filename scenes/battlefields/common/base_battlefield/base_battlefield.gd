class_name BaseBattlefield extends Node2D
## The base battlefield that is used by both the p2p battlfield and the single player battlefield

@export var land: Land
@onready var sky: BattlefieldSky = $Sky
@onready var camera: Camera2D = $Camera2D

## margin for position.x of cat tower and dog tower
const TOWER_MARGIN: int = 700

func get_stage_width() -> int:
	push_error("ERROR: get_stage_width() NOT IMPLEMENTED")
	return 0

func get_stage_height() -> int: 
	push_error("ERROR: get_stage_height() NOT IMPLEMENTED")
	return 0

func get_stage_rect() -> Rect2:
	push_error("ERROR: get_stage_rect() NOT IMPLEMENTED")
	return Rect2()
	
func get_player_data() -> BaseBattlefieldPlayerData:
	push_error("ERROR: get_player_data() NOT IMPLEMENTED")
	return null	
	
func get_land() -> Land:
	return land
	
func get_sky() -> BattlefieldSky:
	return sky
	
func get_camera() -> Camera2D:
	return $Camera2D

## The effect space, this is where all the effects should be placed.
## stuff that are placed here will always be in front of the characters
func get_effect_space() -> Node2D:
	return $EffectSpace

## the danmaku space, used to spawn bullets.
func get_danmaku_space() -> DanmakuSpace:
	return $DanmakuSpace

func _ready() -> void:
	assert(land != null, "ERROR: land not assigned in Battlefield")

func _clean_up():
	# set back to 1 in case user change game speed
	Engine.time_scale = 1
	$Camera2D.allow_user_input_camera_movement(false)
	$Gui.queue_free()
	
	if not Data.mute_sound_fx:
		var inbattle_sfx_idx: int = AudioServer.get_bus_index("InBattleFX")
		AudioServer.set_bus_mute(inbattle_sfx_idx, true)	

func _exit_tree() -> void:
	# in case game is paused (for example by quitting the battle from pause menu) 
	get_tree().paused = false
	AudioPlayer.stop_current_music(true, true)

	AudioPlayer.remove_all_in_battle_sfx()
	
	if not Data.mute_sound_fx:
		var inbattle_sfx_idx: int = AudioServer.get_bus_index("InBattleFX")
		AudioServer.set_bus_mute(inbattle_sfx_idx, false)	
	
	InBattle.clean_up()
	Global.clear_timers()

