class_name P2PDanmakuSpace extends DanmakuSpace

func _config_danmaku_space(_node: BulletsEnvironment) -> void:
	var battlefield := InBattle.get_battlefield() as P2PBattlefield
	
	var ids: Array[String] = []
	ids.append_array(battlefield.get_player_data().team_dog_ids.filter(func(id): return id != null))
	ids.append_array(battlefield.get_opponent_data().team_dog_ids.filter(func(id): return id != null))
	
	var pool_sizes := _get_dogs_bullet_pool_sizes(ids)
	register_bullets(pool_sizes)
