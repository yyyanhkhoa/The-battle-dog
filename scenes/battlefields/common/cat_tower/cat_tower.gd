class_name CatTower extends StaticBody2D

signal zero_health
signal damage_taken

@export var spawn_point: EnemySpawnPoint
@onready var cat_spawn: = spawn_point.cat_spawn
@onready var boss_appeared: = spawn_point.boss_appeared

var health: int
var max_health: int

## position where effect for the tower should take place 
func get_effect_global_position() -> Vector2:
	return $EffectMarker.global_position

func _ready() -> void:
	max_health = InBattle.get_stage_data()['cat_tower_health']
	health = max_health
	update_health_label()

func update_health_label():
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func take_damage(damage: int) -> void:
	if health <= 0:
		return	
	
	# only take full damage if no bosses are on battle
	if spawn_point.alive_boss_count > 0:
		health = max(health - 1, 1) 
	elif spawn_point.bosses_queue.size() > 0:
		health = max(health - damage, 1) 
	else:	
		health = max(health - damage, 0) 
	
	damage_taken.emit()
	$AnimationPlayer.play("shake" if health > 0 else "fall")
	
	while spawn_point.bosses_queue.size() > 0:
		var boss_info = spawn_point.bosses_queue.back()
		if health <= boss_info['health_at']:
			health = boss_info['health_at']
			spawn_point.spawn_boss(boss_info)
			spawn_point.bosses_queue.pop_back()
		else: 
			break
	
	update_health_label()
	
	if health <= 0:		
		for timer in spawn_point.spawn_timers:
			timer.queue_free()			
			
		zero_health.emit()

func spawn(cat_id: String, data: Dictionary = {}, pre_ready_callback := Callable()) -> Character:
	return spawn_point.spawn(cat_id, data, pre_ready_callback)

func knockback_dogs(knockback_scale: float = 2.5) -> void:
	spawn_point.knockback_dogs(knockback_scale)
