extends BattlefieldP2PNetworking

const UPDATE_INTERVAL: float = 1.0 / 25.0
const MAX_TEAM_SIZE: int = 10
const MAX_SKILL_SIZE: int = 3

var _this_player_data: P2PBattlefieldPlayerData
var _opponent_data: P2PBattlefieldPlayerData
var _this_player_dog_tower: P2PDogTower
var _opponent_dog_tower: P2PDogTower

var _delta_passed: float = 0
var _received_message_number: int = 0
var _client_efficiency_upgrade_request_accepted: bool = false

## Used to keep track of client's dogs and skills recharge time.
## The first 10 is for dogs, next 3 is for item
var _opponent_timers: Array[Timer] = []

## skills used by the server, used for notifying to the client
## This will be cleared everytime an authoritative message is sent
var _this_player_used_skills: Array[String] = []

func _ready() -> void:
	SteamUser.set_lobby_data("game_status", "started")
	SteamUser.set_lobby_data("winner", "")
	set_process(false)
	
func setup(
		this_player_data: P2PBattlefieldPlayerData, 
		opponent_player_data: P2PBattlefieldPlayerData, 
		this_player_dog_tower: P2PDogTower,
		opponent_dog_tower: P2PDogTower,
		battle_gui: P2PBattleGUI
	):
	_this_player_data = this_player_data
	_opponent_data = opponent_player_data
	_opponent_dog_tower = opponent_dog_tower
	_this_player_dog_tower = this_player_dog_tower
	
	for index in range(MAX_TEAM_SIZE):
		var dog_id = _opponent_data.team_dog_ids[index]
		if dog_id == null:
			_opponent_timers.append(null)
			continue
			
		var timer: = Timer.new()
		timer.wait_time = max(Data.dog_info[dog_id]['spawn_time'], 0.05)
		timer.one_shot = true		
		_opponent_timers.append(timer)
		add_child(timer)
		
	for index in range(MAX_SKILL_SIZE):
		var skill_id = _opponent_data.team_skill_ids[index]
		if skill_id == null:
			_opponent_timers.append(null)
			continue
			
		var timer: = Timer.new()
		timer.wait_time = Data.skill_info[skill_id]['spawn_time']
		timer.one_shot = true		
		_opponent_timers.append(timer)
		add_child(timer)		
		print(Data.skill_info[skill_id]['spawn_time'])
	
	this_player_dog_tower.zero_health.connect(
		end_game.bind(_opponent_data.get_steam_id()), CONNECT_ONE_SHOT
	)
	opponent_dog_tower.zero_health.connect(
		end_game.bind(SteamUser.STEAM_ID), CONNECT_ONE_SHOT
	)
	
	battle_gui.surrendered.connect(_on_surrendered)
	
	set_process(true)
	
func _process(delta: float):
	_this_player_data.update(delta)	
	_opponent_data.update(delta)
	
	_apply_client_messages()
	
	# authoritative message are in a fixed interval (tick)
	_delta_passed += delta
	if _delta_passed >= UPDATE_INTERVAL:
		_delta_passed -= UPDATE_INTERVAL
		var message := {
			'dog_tower_health': _opponent_dog_tower.health,
			'opponent_dog_tower_health': _this_player_dog_tower.health,
			'fmoney': _opponent_data.fmoney,
			'received_message_number': _received_message_number
		}
		
		if _client_efficiency_upgrade_request_accepted:
			message['efficiency_level'] = _opponent_data.get_efficiency_level()
			_client_efficiency_upgrade_request_accepted = false
		
		if _opponent_data.input_mask != 0:
			message['accepted_input_requests'] = _opponent_data.input_mask
			
		_add_if_not_empty('opponent_skills', _this_player_used_skills, message)
		
		_add_if_not_empty('recharge_times', _get_client_recharge_times(), message)
		
		# Note: sync array should always be sent, even if it is empty
		message['sync'] = _get_game_objects_sync_data(message)

		SteamUser.send_message(message, SteamUser.SendType.RELIABLE)
		
		_opponent_data.input_mask = 0

func _add_if_not_empty(key: String, array_or_dict: Variant, message: Dictionary):
	if array_or_dict.size() > 0:
		message[key] = array_or_dict

func _get_game_objects_sync_data(message: Dictionary) -> Array:
	var sync_objects = get_tree().get_nodes_in_group("p2p_sync")
	
	## by convention every object that is in the "p2p_sync" group
	## will implement a "get_sync_data()" function
	var sync_objects_data = sync_objects.map(
		func(obj: Object): return obj.get_p2p_sync_data()
	)
	
	return sync_objects_data

func _get_client_recharge_times() -> Array:
	var client_recharge_times = _opponent_timers.map(
		func (timer: Timer):
			return null if timer == null else timer.time_left	
	)
	return client_recharge_times
	
func _apply_client_messages():
	for message in SteamUser.read_messages():
		var data: Dictionary = message['data']
		if data.has('surrender'):
			_handle_client_surrender()
			return
			
		_received_message_number = data['message_number']
		
		var input_mask: int = data['input_mask']
		_handling_client_spawn(input_mask)
		_handling_client_skill(input_mask)
		_handling_efficiency_upgrade(input_mask)

func _handling_client_spawn(input: int):
	for i in range(10):
		var input_mask: int = (1 << i)
		var request_spawn: bool = input & input_mask == input_mask
		var dog_id = _opponent_data.team_dog_ids[i]
		if not request_spawn or dog_id == null:
			continue
			
		var timer := _opponent_timers[i]
		var spawn_ready: bool = timer.is_stopped()
		if not spawn_ready:
			continue
		
		var spawn_price: int = Data.dog_info[dog_id]['spawn_price']
		var can_afford: bool = _opponent_data.get_money_int() >= spawn_price
		
		var spawn_limit: int = Data.dog_info[dog_id].get("spawn_limit", 0)
		var can_spawn := true
		if  spawn_limit > 0 and _opponent_data.dogs_count[dog_id] >= spawn_limit:
			can_spawn = false
			
		if can_afford and can_spawn:
			_opponent_data.input_mask |= input_mask
			_opponent_data.fmoney -= spawn_price
			var dog: BaseDog = _opponent_dog_tower.spawn(dog_id)	
			timer.start()
			
func _handling_client_skill(input: int):	
	for i in range(3):
		var input_mask: int = (1 << MAX_TEAM_SIZE + i)
		var request_skill: bool = input & input_mask == input_mask
		var skill_id = _opponent_data.team_skill_ids[i]
		
		if not request_skill or skill_id == null:
			continue
			
		var timer := _opponent_timers[MAX_TEAM_SIZE + i]
		var spawn_ready: bool = timer.is_stopped()
		if not spawn_ready:
			continue
		
		_opponent_data.input_mask |= input_mask   
		_opponent_dog_tower.use_skill(skill_id)	
		timer.start()
			
func _handling_efficiency_upgrade(input_mask: int):
	var request_upgrade: bool = input_mask & (1 << 13) == (1 << 13)
	if not request_upgrade:
		return
		
	var upgrade_price: int = _opponent_data.get_efficiency_upgrade_price() 
	var can_upgrade: bool = _opponent_data.get_money_int() >= upgrade_price
	if can_upgrade:
		_opponent_data.fmoney -= upgrade_price
		_opponent_data.increase_efficiency_level()
		_client_efficiency_upgrade_request_accepted = true

func _handle_client_surrender():
	end_game(_this_player_data.get_steam_id())

func request_efficiency_upgrade():
	if _this_player_data.get_efficiency_level() < _this_player_data.MAX_EFFICIENCY_LEVEL:
		_this_player_data.fmoney -= _this_player_data.get_efficiency_upgrade_price()
		_this_player_data.increase_efficiency_level()
	
	upgrade_efficiency_request_accepted.emit()
	
func request_spawn(dog_id: String):
	var spawn_price: int = Data.dog_info[dog_id]['spawn_price']
	_this_player_data.fmoney -= spawn_price
	
	var dog = _this_player_dog_tower.spawn(dog_id)
	
	spawn_request_accepted.emit(dog_id)
		
func request_skill(skill_id: String):
	_this_player_dog_tower.use_skill(skill_id)
	skill_request_accepted.emit(skill_id)
	_this_player_used_skills.append(skill_id)
				
func end_game(winner_id: int) -> void:
	SteamUser.send_message({ "winner": winner_id }, SteamUser.SendType.RELIABLE)
	
	InBattle.get_battlefield().end_game(winner_id)
	
func _on_surrendered() -> void:
	end_game(_opponent_data.get_steam_id())
