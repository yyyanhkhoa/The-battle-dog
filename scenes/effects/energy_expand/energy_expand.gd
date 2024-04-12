class_name FXEnergyExpand extends Sprite2D

var _sync_data: Dictionary

## anim_type can be "on_subject" or "on_emitter"
func setup(global_position: Vector2, anim_type: String) -> void:
	self.global_position = global_position
	self.visible = true
	$AnimationPlayer.play(anim_type)
	
	_sync_data = { 
		"object_type": P2PObjectSync.ObjectType.EFFECT,
		"scene": InBattle.SCENE_FX_ENERGY_EXPAND,
		"instance_id": get_instance_id(),
		"position": position,
		"anim_type": anim_type
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
	
func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(func(_name: String): queue_free())

func get_p2p_sync_data() -> Dictionary:
	## only need to sync once for energy expand effect
	remove_from_group(P2PObjectSync.SYNC_GROUP)
	return _sync_data
	
func p2p_setup(sync_data: Dictionary):
	setup(sync_data['position'], sync_data['anim_type'])

func p2p_sync(sync_data: Dictionary) -> void:
	position = sync_data['position']
	
func p2p_remove() -> void:
	## do nothing because the effect will automatically disappeared after completion
	return
