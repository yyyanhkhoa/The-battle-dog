class_name TwoTowersBattlefield extends Battlefield

@export var cat_tower: CatTower

func _ready() -> void:
	assert(cat_tower != null, "ERROR: cat tower not assigned in Battlefield")
	super()
	cat_tower.position.x = get_stage_width() - TOWER_MARGIN;
	cat_tower.zero_health.connect(_win, CONNECT_ONE_SHOT)
	cat_tower.boss_appeared.connect(_on_boss_appeared)

func _win() -> void:
	super()

	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var position_x: float = min(cat_tower.global_position.x, get_stage_width()- Global.VIEWPORT_SIZE.x * 0.5 / camera.zoom.x)
	tween.tween_property(camera, "position:x", position_x, 2.0)

func _defeat() -> void:
	super()

	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position:x", Global.VIEWPORT_SIZE.x * 0.5 / camera.zoom.x, 2.0)
