extends Battlefield

@export var enemy_spawn_point: EnemySpawnPoint

@onready var win_battle_raycast: RayCast2D = $WinBattleRaycast

func _ready() -> void:
	super()
	
	## move spawn point outside of battlefield
	enemy_spawn_point.position.x = get_stage_width() + TOWER_MARGIN
	enemy_spawn_point.boss_appeared.connect(_on_boss_appeared)
	
	win_battle_raycast.position.x = get_stage_width() + 100
		
func _physics_process(delta: float) -> void:
	if win_battle_raycast.is_colliding():
		_win()
		set_physics_process(false)
	

func _win() -> void:
	super()
	enemy_spawn_point.queue_free()
