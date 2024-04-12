extends BattlefieldP2PNetworking

var _this_player_data: P2PBattlefieldPlayerData
var _opponent_data: P2PBattlefieldPlayerData
var _this_player_dog_tower: P2PDogTower
var _opponent_dog_tower: P2PDogTower

var _message_number: int = 0

var _p2p_object_sync: P2PObjectSync

func _ready() -> void:
	set_process(false)

func setup(
		battlefield: P2PBattlefield,
		this_player_data: P2PBattlefieldPlayerData, 
		opponent_player_data: P2PBattlefieldPlayerData, 
		this_player_dog_tower: P2PDogTower,
		opponent_dog_tower: P2PDogTower,
		battle_gui: P2PBattleGUI
	):
	_this_player_data = this_player_data
	_opponent_data = opponent_player_data
	_this_player_dog_tower = this_player_dog_tower
	_opponent_dog_tower = opponent_dog_tower
	_p2p_object_sync = P2PObjectSync.new()
	set_process(true)
	
	if this_player_dog_tower.direction == P2PDogTower.Direction.LEFT_TO_RIGHT:
		_p2p_object_sync.setup(battlefield, this_player_dog_tower, opponent_dog_tower)
	else:
		_p2p_object_sync.setup(battlefield, opponent_dog_tower, this_player_dog_tower)

	battle_gui.surrendered.connect(_on_surrendered)
	
## update game state using data sent from server
func _process(delta: float):	
	for message in SteamUser.read_messages():
		var data: Dictionary = message['data']
		if data.has('fmoney'):
			_this_player_data.fmoney = data['fmoney']
		
		if data.has('dog_tower_health'):
			_this_player_dog_tower.set_health(data['dog_tower_health'])	
		
		if data.has('opponent_dog_tower_health'):
			_opponent_dog_tower.set_health(data['opponent_dog_tower_health'])		
		
		if data.has('efficiency_level'):
			_handling_efficiency_upgrade(data['efficiency_level'])
		
		if data.has('accepted_input_requests'):
			_handling_accepted_input_requests(data['accepted_input_requests'])
			
		if data.has('recharge_times'):
			_handling_recharge_times(data['recharge_times'])
		
		if data.has('sync'):
			_hanlding_game_objects_sync(data['sync'])
		
		if data.has('winner'):
			_on_game_end(data['winner'])
			
	_this_player_data.update(delta)
	
	# input are send every frame
	if _this_player_data.input_mask != 0:
		_message_number += 1
		SteamUser.send_message({
			'input_mask': _this_player_data.input_mask,
			'message_number': _message_number
		}, SteamUser.SendType.RELIABLE)
		_this_player_data.input_mask = 0

func _handling_efficiency_upgrade(level: int) -> void:
	var upgrade_count = level - _this_player_data.get_efficiency_level()
	for i in range(0, upgrade_count):
		_this_player_data.increase_efficiency_level()
		
	upgrade_efficiency_request_accepted.emit()

func _handling_accepted_input_requests(input: int) -> void:
	for i in range(10):
		var input_mask: int = (1 << i)
		var request_accepted: bool = input & input_mask == input_mask
		var dog_id = _this_player_data.team_dog_ids[i]
		if not request_accepted or dog_id == null:
			continue
			
		spawn_request_accepted.emit(dog_id)
		
	for i in range(3):
		var input_mask: int = (1 << 10 + i)
		var request_accepted: bool = input & input_mask == input_mask
		var skill_id = _this_player_data.team_skill_ids[i]
		if not request_accepted or skill_id == null:
			continue
			
		skill_request_accepted.emit(skill_id)

func _handling_recharge_times(recharge_times: Array):
	for i in range(10):
		var dog_id = _this_player_data.team_dog_ids[i]
		if dog_id != null:
			var recharge_time: float = recharge_times[i]
			spawn_recharge_time_updated.emit(dog_id, recharge_time)
		
	for i in range(3):
		var dog_id = _this_player_data.team_skill_ids[i]
		if dog_id != null:
			var recharge_time: float = recharge_times[10 + i]
			skill_recharge_time_updated.emit(dog_id, recharge_time)
		
func _hanlding_game_objects_sync(sync_objects_data: Array):
	_p2p_object_sync.reset_sync_status()
	
	for sync_data in sync_objects_data:
		var server_instance_id: int = sync_data['instance_id']
		
		if not _p2p_object_sync.has_instance(server_instance_id):
			_p2p_object_sync.add_instance(sync_data)
			
		_p2p_object_sync.sync_instance(sync_data)
		
	_p2p_object_sync.remove_unsynced_instances()

## send upgrade input to server, waiting for response
func request_efficiency_upgrade():
	_this_player_data.input_mask |= (1 << 13) 

## send spawn input to server, waiting for response
func request_spawn(dog_id: String):
	var index: int = _this_player_data.team_dog_ids.find(dog_id)
	_this_player_data.input_mask |= (1 << index)

## send skill input to server, waiting for response
func request_skill(skill_id: String):
	const SKILL_BIT_OFFSET: int = 10
	var index: int = _this_player_data.team_skill_ids.find(skill_id) + SKILL_BIT_OFFSET
	_this_player_data.input_mask |= (1 << index)

func _on_game_end(winner_id: int) -> void:
	# update tower health before showing game end scene
	if winner_id == SteamUser.STEAM_ID:
		_opponent_dog_tower.set_health(0) 
		_opponent_dog_tower.kill_all_dogs() 
	else:
		_this_player_dog_tower.set_health(0)
		_this_player_dog_tower.kill_all_dogs() 
	
	InBattle.get_battlefield().end_game(winner_id)
	
	set_process(false)
	
	## clear all messages before close
	while SteamUser.read_messages().size() > 0:
		continue
	
	queue_free()

func _on_surrendered() -> void:
	_message_number += 1
	SteamUser.send_message({
		'surrender': true,
		'message_number': _message_number
	}, SteamUser.SendType.RELIABLE)
