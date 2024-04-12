class_name P2PObjectSync extends RefCounted

## Objects within this group will be sync by the client using data sent from the server [/br]
## Objects within this group must implement these funtions: [/br]
## get_p2p_sync_data() -> Dictionary [/br]
## p2p_setup(sync_data: Dictionary) -> void [/br]
## p2p_sync(sync_data: Dictionary) -> void [/br]
## p2p_remove() -> void [/br]
const SYNC_GROUP = "p2p_sync"

enum ObjectType { DOG, SKILL, EFFECT }
var _objectFactory: Dictionary = {
	ObjectType.DOG: _add_dog,
	ObjectType.SKILL: _add_skill,
	ObjectType.EFFECT: _add_effect,
}

## mapping game object instances between server and client. 
## Map server id to client id 
var instance_map := {}
var synced_map := {}

var _battlefield: P2PBattlefield
var _dog_tower_left: P2PDogTower
var _dog_tower_right: P2PDogTower

func setup(battlefield: P2PBattlefield, dog_tower_left: P2PDogTower, dog_tower_right: P2PDogTower):
	_battlefield = battlefield
	_dog_tower_left = dog_tower_left
	_dog_tower_right = dog_tower_right

func has_instance(server_id: int) -> bool:
	return instance_map.has(server_id)

func get_instance(server_id: int) -> Node:
	return instance_from_id(instance_map[server_id])

## this should be called after all of the available instances received from the server 
## have been synced to remove any client instances that no longer exist on the server
func remove_unsynced_instances() -> void:
	for id in synced_map:
		if synced_map[id] == false:
			remove_instance(id)

## reset instances sync status to false, should be called before doing every new sync session
func reset_sync_status() -> void:
	for id in synced_map:
		synced_map[id] = false	
		
func remove_instance(server_id: int) -> void:
	var instance = get_instance(server_id)
	
	instance.p2p_remove()
	
	_erase_from_maps(server_id)
	
func _erase_from_maps(server_id: int) -> void:
	instance_map.erase(server_id) 
	synced_map.erase(server_id)
	
func sync_instance(sync_data: Dictionary) -> void:
	get_instance(sync_data['instance_id']).p2p_sync(sync_data)
	synced_map[sync_data['instance_id']] = true

func add_instance(sync_data: Dictionary) -> Node:
	sync_data['p2p_object_sync'] = self
	var instance = _objectFactory[sync_data['object_type']].call(sync_data) as Node
	
	# in cases where instance might already gone in the client before the server notify it's removal
	instance.tree_exiting.connect(_erase_from_maps.bind(sync_data['instance_id']))
	
	instance_map[sync_data['instance_id']] = instance.get_instance_id()
	synced_map[sync_data['instance_id']] = false
	return instance
	
func _add_dog(sync_data: Dictionary) -> BaseDog:
	var dog_tower: P2PDogTower = (
		# right to left characters will act as a "Cat"
		_dog_tower_right if sync_data['character_type'] == Character.Type.CAT
		else _dog_tower_left
	)
	
	var dog_id: String = sync_data['dog_id']
	var dog := dog_tower.spawn(dog_id)
	
	return dog
	
## will not return BaseSkill since some skill will create children not of that type
func _add_skill(sync_data: Dictionary) -> Node:
	var scene := InBattle.get_packed_scene(sync_data['scene'])
	var skill = scene.instantiate()
	_battlefield.add_child(skill)
	skill.p2p_setup(sync_data)
	return skill
	
func _add_effect(sync_data: Dictionary) -> Node:
	var scene := InBattle.get_packed_scene(sync_data['scene'])
	var effect = scene.instantiate()
	_battlefield.get_effect_space().add_child(effect)
	effect.p2p_setup(sync_data)
	return effect
