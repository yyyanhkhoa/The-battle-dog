class_name Battlefield extends BaseBattlefield
## The base battlefield class for single player battlefields

var VictoryGUI: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/defeat_gui/defeat_gui.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")
var BOSS_DRUM: AudioStream = preload("res://resources/sound/battlefield/boss_drum.mp3") 

@export var dog_tower: BaseDogTower

var _boss_music: AudioStream
var _player_data: BattlefieldPlayerData
var _stage_data: Dictionary

func _init() -> void:
	InBattle.in_p2p_battle = false
	InBattle.in_request_mode = false
	_stage_data = InBattle.load_stage_data()
	_player_data = BattlefieldPlayerData.new()
	
func get_stage_width() -> int: return _stage_data['stage_width'] + TOWER_MARGIN * 2

func get_stage_height() -> int: 
	return land.get_land_bottom_y() - sky.position.y
	
func get_stage_rect() -> Rect2:
	return Rect2(0, sky.position.y, get_stage_width(), get_stage_height())

func get_player_data() -> BaseBattlefieldPlayerData: return _player_data

func get_dog_tower() -> DogTower:
	return dog_tower
	
func get_cat_power_scale() -> float:
	return _stage_data.get('power_scale', 1.0)

func _ready() -> void:
	super()
	
	$Gui.setup(dog_tower, _player_data)
	$store_gui.setup(dog_tower, _player_data)
	
	$Camera2D.setup(($Gui as BattleGUI).camera_control_buttons, get_stage_rect())
	
	AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % _stage_data['music']))
	
	if _stage_data.get('boss_music') != null:
		_boss_music = load("res://resources/sound/music/%s.mp3" % _stage_data['boss_music'])
		
	dog_tower.position.x = TOWER_MARGIN
	dog_tower.zero_health.connect(_defeat, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	_player_data.update(delta)
	
func _win():
	_kill_all_cats()
	_clean_up()
	
	AudioPlayer.stop_current_music(true, true)
	AudioPlayer.play_music(VICTORY_AUDIO)
	add_child(VictoryGUI.instantiate())	
	
func _kill_all_cats() -> void:
	for cat in get_tree().get_nodes_in_group("cats"):
		cat.kill()

func _defeat():
	_clean_up()
	AudioPlayer.stop_current_music(true, true)
	AudioPlayer.play_music(DEFEAT_AUDIO)
	add_child(DefeatGUI.instantiate())	

func _on_boss_appeared() -> void:
	var game_speed_button := ($Gui as BattleGUI).game_speed_button
	if game_speed_button.is_actived():
		game_speed_button.toggle_game_speed()
	
	var current_music = AudioPlayer.get_current_music()
	if _boss_music != null and current_music != _boss_music:
		AudioPlayer.stop_music(current_music, false, true)
		await AudioPlayer.play_in_battle_sfx_once(BOSS_DRUM, 1.0, true)
		AudioPlayer.play_music(_boss_music)
	else:
		AudioPlayer.play_in_battle_sfx_once(BOSS_DRUM, 1.0, true)

