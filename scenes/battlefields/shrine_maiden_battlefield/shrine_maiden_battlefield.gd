extends TwoTowersBattlefield

func _enter_tree() -> void:
	var tori_data: Dictionary = _stage_data['tori']
	$Tori.setup(
		tori_data['position'], 
		tori_data['health'],
		tori_data['growls'],
		tori_data.get("instant_spawns", {})
	)

func _ready() -> void:
	super()
	cat_tower.position.x = get_stage_width() + TOWER_MARGIN;
	cat_tower.setup($Tori)
	
