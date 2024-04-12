class_name P2PBattlefieldPlayerData extends BaseBattlefieldPlayerData

## first 10 bit represent the spawn buttons, next 3 represent skill buttons and the 
## last bit represent the efficiency upgrade button 
var input_mask := 0b00000000000000

var _member_id: int
func get_steam_id() -> int: return _member_id

func _init(member_id: int) -> void:
	_member_id = member_id
	var team_setup = JSON.parse_string(SteamUser.get_member_data(member_id, "team_setup"))
			
	team_dog_ids = team_setup['dog_ids']
	for id in team_dog_ids:
		team_dog_scenes.append(null if id == null else load("res://scenes/characters/dogs/%s/%s.tscn" % [id, id]))
	
	team_skill_ids = team_setup['skill_ids']
	for id in team_skill_ids:
		team_skill_scenes.append(null if id == null else load("res://scenes/skills/%s/%s.tscn" % [id, id]))
	
	for dog_id in team_dog_ids:
		if dog_id != null:
			dogs_count[dog_id] = 0
	
	fmoney = 0
	
	var efficiency_level := int(SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_MONEY_EFFICIENCY_LEVEL))
	_wallet = int(BASE_WALLET_CAPACITY * (1 + efficiency_level * 0.5))
	_money_rate = BASE_MONEY_RATE * (1 + efficiency_level * 0.1)
	_efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE * (1 + efficiency_level * 0.1)
	_efficiency_level = 1

func get_skill_level(skill_id: String) -> int:
	return int(SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_POWER_LEVEL))
