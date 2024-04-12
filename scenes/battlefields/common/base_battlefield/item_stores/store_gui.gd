class_name StoreGUI extends CanvasLayer

var _dog_tower :DogTower
func setup(dog_tower: DogTower, player_data: BaseBattlefieldPlayerData):
	var store_ids: Array = player_data.team_store_ids
	
	for item in store_ids:
		if item != null and Data.store.has(item) and Data.store[item]['amount'] > 0:
#			and (Data.store_info[item]["auto_activate"] == true)
			var index = player_data.team_store_ids.find(item)
			var store := player_data.team_store_scenes[index].instantiate()
			get_tree().current_scene.add_child(store)
			store.store_setup(dog_tower,player_data)

