extends Node

var in_p2p_battle: bool = false

## wether or not the player is in a p2p game, and is a client peer, 
## which can only make requests and every actions in the game needs to be confirm by the server 
var in_request_mode: bool = false

## preloaded scenes
const SCENE_FX_HIT: String = "res://scenes/effects/fx_hit/hit.tscn"
const SCENE_FLYING_SOUL: String = "res://scenes/effects/flying_soul/flying_soul.tscn"
const SCENE_FX_ENERGY_EXPAND: String = "res://scenes/effects/energy_expand/energy_expand.tscn"

## load when needed scene
const SCENE_FIRE_BALL: String = "res://scenes/skills/fire_ball/ball.tscn"
const SCENE_HEALING: String = "res://scenes/skills/healing/healing.tscn"

var _packed_scenes = {
	SCENE_FX_HIT: preload(SCENE_FX_HIT),
	SCENE_FLYING_SOUL: preload(SCENE_FLYING_SOUL),
	SCENE_FX_ENERGY_EXPAND: preload(SCENE_FX_ENERGY_EXPAND),
}

var _fx_hit_pool := FxHitPool.new()

## get packed scene from cache, will load packed scene and returns it if it does not cache it yet
func get_packed_scene(scene_path: String) -> PackedScene:
	if not _packed_scenes.has(scene_path):
		_packed_scenes[scene_path] = load(scene_path)
		
	return _packed_scenes[scene_path] 
		
## add a hit effect to the battlefield
func add_hit_effect(global_position: Vector2) -> FXHit:	
	var fx_hit := _fx_hit_pool.get_hit_effect()
	fx_hit.setup(global_position)
	get_battlefield().get_effect_space().add_child(fx_hit)
	return fx_hit

func get_battlefield() -> BaseBattlefield:
	return get_tree().current_scene if get_tree() != null else null
	
var _stage_data: Dictionary
## this will not work in p2p battle
func get_stage_data() -> Dictionary:
	return _stage_data
	
## load data from stage file
func load_stage_data() -> Dictionary:
	var dir = "%s/stages/%s.%s.json" % [
		Data.selected_chapter_dir_path,
		Data.selected_stage,
		Data.selected_stage_id,
	]
	var file = FileAccess.open(dir, FileAccess.READ)
	var stage_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
		
	_stage_data = stage_data
	return stage_data

func get_danmaku_space() -> DanmakuSpace:
	return get_battlefield().get_danmaku_space()

func get_effect_space() -> Node2D:
	return get_battlefield().get_effect_space()

func get_player_data() -> BaseBattlefieldPlayerData:
	return get_battlefield().get_player_data()
	
## only works if is in p2p mode
func get_opponent_data() -> P2PBattlefieldPlayerData:
	return (get_battlefield() as P2PBattlefield)._opponent_player_data
	
## Helper function to get skill level of player or enemy depeneding on the given 'skill_user' 
func get_skill_level(skill_id: String, skill_user: Character.Type) -> int:
	if not in_p2p_battle:
		return get_player_data().get_skill_level(skill_id)
		
	var battlefield := get_battlefield() as P2PBattlefield
	var player_data: P2PBattlefieldPlayerData
	if skill_user == Character.Type.DOG:
		player_data = battlefield.get_dog_tower_left().get_player_data()
	else:
		player_data = battlefield.get_dog_tower_right().get_player_data()
	
	return player_data.get_skill_level(skill_id)

func get_dog_level(dog_id: String) -> int:
	if not in_p2p_battle:
		return Data.dogs[dog_id]['level']
	
	return int(SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_POWER_LEVEL))

func get_dog_abilities(dog_id: String) -> Array[String]:
	var abilities: Array[String] = []
	
	if not in_p2p_battle:
		abilities.assign(Data.dogs[dog_id]['abilities'])

	## in p2p battle, dogs have learned all abilities
	return abilities
	
func get_passive_level(passive_id: String) -> int:
	if in_p2p_battle:
		push_error("Error: get_passive_level(passive_id: String) not implemented")
		return 0
	
	return get_player_data().get_passive_level(passive_id) 

func clean_up() -> void:
	_fx_hit_pool.clear()
