@tool
class_name MikoDog extends BaseDog

## this value could be different if miko dog is a Cat (enemy Dog)
var ofuda_damage: float = 10

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		return
	
	get_FSM().state_entering.connect(_on_state_entering)
	var shape: RectangleShape2D = $AirUnitDetector/CollisionShape2D.shape
	shape.size.y = InBattle.get_battlefield().get_stage_height()	
	$AirUnitDetector/CollisionShape2D.position.y = -shape.size.y * 0.5
	
func _on_state_entering(state_name: String, data: Dictionary) -> void:
	if InBattle.in_request_mode or state_name != "AttackState":
		return

	var enemies := get_tree().get_nodes_in_group(
		 "cats" if character_type == Character.Type.DOG else "dogs"
	)
	
	var air_units: Array[Node2D] = %AirUnitDetector.get_overlapping_bodies()
	
	if not air_units.is_empty():
		data['attack_point'] = air_units.pick_random().global_position
	elif not enemies.is_empty():
		data['attack_point'] = enemies.pick_random().global_position
	else:
		data['attack_point'] = Vector2(global_position.x + attack_range * 2 * move_direction, global_position.y)

func _update_character() -> void:
	super()
	var shape: RectangleShape2D = $AirUnitDetector/CollisionShape2D.shape
	shape.size.x = attack_range
	$AirUnitDetector/CollisionShape2D.position.x = n_RayCast2D.position.x + shape.size.x * 0.5 * move_direction
