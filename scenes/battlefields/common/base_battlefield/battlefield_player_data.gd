class_name BattlefieldPlayerData extends BaseBattlefieldPlayerData

func _init() -> void:
	team_dog_ids.append_array(Data.selected_team['dog_ids'].duplicate())
	for id in team_dog_ids:
		team_dog_scenes.append(null if id == null else load("res://scenes/characters/dogs/%s/%s.tscn" % [id, id]))
		
	team_skill_ids.append_array(Data.selected_team['skill_ids'])
	for id in team_skill_ids:
		team_skill_scenes.append(null if id == null else load("res://scenes/skills/%s/%s.tscn" % [id, id]))
		
	team_store_ids.append_array(Data.selected_team['store_ids'])
	for id in team_store_ids:
		team_store_scenes.append(null if id == null else load("res://scenes/stores/%s/%s.tscn" % [id, id]))
	
	for dog_id in team_dog_ids:
		if dog_id != null:
			dogs_count[dog_id] = 0
	
	fmoney = 0
	_wallet = int(BASE_WALLET_CAPACITY * (1 + _get_level_or_zero(Data.passives.get('wallet_capacity')) * 0.5))
	_money_rate = BASE_MONEY_RATE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1)
	_efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1)
	_efficiency_level = 1

func _get_level_or_zero(dict: Variant) -> int:
	return 0 if dict == null else dict.get('level', 0)

func get_skill_level(skill_id: String) -> int:
	return _get_level_or_zero(Data.skills.get(skill_id))

func get_passive_level(passive_id: String) -> int:
	return _get_level_or_zero(Data.passives.get(passive_id))
