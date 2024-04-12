@tool
class_name SunflowerFairyCat extends AirUnitCat

func _create_floating_movement_tween(nodes: Array[Node2D]) -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_loops().set_parallel()
	
	for node in nodes: 
		tween.tween_property(node, "position:y", 20.0, 0.4).as_relative()

	tween.chain()
	for node in nodes: 
		tween.tween_property(node, "position:y", -20.0, 0.4).as_relative()
	
	return tween
