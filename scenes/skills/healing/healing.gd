extends BaseSkill

var _heal_amount = 5000
var _sync_data: Dictionary 

func setup(skill_user: Character.Type) -> void:
	_sync_data = { 
		"object_type": P2PObjectSync.ObjectType.SKILL,
		"scene": InBattle.SCENE_HEALING,
		"instance_id": get_instance_id(),
		"skill_user": skill_user,
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
	
	var level := InBattle.get_skill_level('healing', skill_user)
	_heal_amount = _heal_amount * level
		
	## currently, only dog tower can call this skill
	## so only enemy dog tower (p2p mode) can use this and not cat tower
	var dog_tower: BaseDogTower
	if not InBattle.in_p2p_battle:
		dog_tower = (InBattle.get_battlefield() as Battlefield).get_dog_tower()
	else:
		var battlefield := InBattle.get_battlefield() as P2PBattlefield
		dog_tower = (
			battlefield.get_dog_tower_left() if skill_user == Character.Type.DOG
			else battlefield.get_dog_tower_right()
		)
	
	self.global_position = dog_tower.global_position + Vector2(0, -500)
	
	if not InBattle.in_request_mode:
		var tween = dog_tower.healing(_heal_amount)
		tween.finished.connect(func(): die())

func die():
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()

func get_p2p_sync_data() -> Dictionary:
	return _sync_data
	
func p2p_setup(sync_data: Dictionary) -> void:
	setup(sync_data['skill_user'])

func p2p_sync(sync_data: Dictionary) -> void:
	return
	
func p2p_remove() -> void:
	die()
