class_name FxHitPool extends RefCounted

var FX_HIT: PackedScene = preload("res://scenes/effects/fx_hit/hit.tscn")

var _fx_hits: Dictionary = {}	
var _unused_fx_hits: Array[FXHit] = []
var _timer_ids_to_be_unused: Array[Vector2] = []

## get the hit fx, note: do not queue free the fx
func get_hit_effect() -> FXHit:
	var fx_hit: FXHit	
	if _unused_fx_hits.is_empty():
		fx_hit = FX_HIT.instantiate()
		_fx_hits[fx_hit] = fx_hit
	else:
		fx_hit = _unused_fx_hits.pop_back()
		_fx_hits[fx_hit] = fx_hit
	
	fx_hit.tree_exited.connect(_put_to_unused.bind(fx_hit), CONNECT_ONE_SHOT)
	return fx_hit
	
func _put_to_unused(fx_hit: FXHit) -> void:
	_fx_hits.erase(fx_hit)
	_unused_fx_hits.append(fx_hit)

func clear() -> void:
	for fx_hit: FXHit in _fx_hits:
		fx_hit.tree_exited.disconnect(_put_to_unused)
		fx_hit.queue_free()
		
	for fx_hit in _unused_fx_hits:
		fx_hit.queue_free()
		
	_fx_hits.clear()
	_unused_fx_hits.clear()
