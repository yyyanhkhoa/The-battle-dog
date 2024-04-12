extends Sprite2D

const TOP_PADDING = 20;

var _character : Character
var _sync_data: Dictionary

func setup(duration: float, character: Character) -> void:
	_sync_data = {
		"object_type": P2PObjectSync.ObjectType.EFFECT,
		"scene": "res://scenes/skills/power_up/sprite.tscn",
		"instance_id": get_instance_id(),
		"duration": duration,
		"target_instance_id": character.get_instance_id()
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
	
	_character = character
	var collision_rect := _character.collision_rect
	var new_scale := collision_rect.size.x / get_rect().size.x;
	scale = Vector2(new_scale, new_scale)
	_update_position()
	
	$AnimationPlayer.play("play")
	
	_character.tree_exiting.connect(func(): queue_free())
	
	if not InBattle.in_request_mode:
		await get_tree().create_timer(duration, false).timeout
		queue_free()

func _process(delta) -> void:
	_update_position()

func _update_position() -> void:
	var collision_rect := _character.collision_rect
	self.global_position = _character.global_position
	self.global_position.y += collision_rect.position.y - (collision_rect.size.y / 2) - TOP_PADDING
	
func get_p2p_sync_data() -> Dictionary:
	return _sync_data
	
func p2p_setup(sync_data: Dictionary) -> void:
	var p2p_object_sync := sync_data['p2p_object_sync'] as P2PObjectSync
	
	## check if targeting object still exists to apply the effect to
	if p2p_object_sync.has_instance(sync_data['target_instance_id']):
		var target = p2p_object_sync.get_instance(sync_data['target_instance_id'])
		setup(sync_data['duration'], target) 
	else:
		p2p_remove()

## client automatically update the position
func p2p_sync(sync_data: Dictionary) -> void:
	return
	
func p2p_remove() -> void:
	queue_free()
