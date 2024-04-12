class_name TwoTowersBattlefield extends Battlefield

@export var cat_tower: CatTower

func _ready() -> void:
	assert(cat_tower != null, "ERROR: cat tower not assigned in Battlefield")
	super()
	cat_tower.position.x = get_stage_width() - TOWER_MARGIN;
	cat_tower.zero_health.connect(_win, CONNECT_ONE_SHOT)
	cat_tower.boss_appeared.connect(_on_boss_appeared)
