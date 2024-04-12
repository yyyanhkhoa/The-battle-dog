class_name BaseDogTower extends StaticBody2D

signal zero_health
signal dog_spawn(dog: BaseDog)

var health: int
var max_health: int

## position where effect for the tower should take place 
func get_effect_global_position() -> Vector2:
	return $Marker2D.global_position

func spawn(dog_id: String) -> BaseDog:
	push_error("ERROR: spawn(dog_id: String) not implemented")
	return null
		
func update_health_label():
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func take_damage(damage: int) -> void:
	if health <= 0:
		return
	
	if not InBattle.in_request_mode:
		health = max(health - damage, 0) 
	
	update_health_label()
	$AnimationPlayer.play("shake" if health > 0 else "fall")
	
	if health <= 0:
		zero_health.emit()
	
func healing(heal : int) -> Tween :
	var new_health = min(health + heal, max_health) 
	
	var tween := create_tween()
	tween.tween_method(func(value: float):
		health = value	
		update_health_label()
	, health, new_health, 4)
	tween.play()
	
	return tween
