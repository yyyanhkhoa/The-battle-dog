class_name DogTower extends BaseDogTower

const WIZARD_DOG_SCENE: PackedScene = preload("res://scenes/battlefields/common/dog_tower/gandolfg/gandolfg.tscn")

var _player_data: BattlefieldPlayerData

func get_sprite_node() -> Sprite2D:
	return $Sprite2D

func _ready() -> void:
	if InBattle.get_passive_level('gandolfg') > 0:
		var gandolfg: Gandolfg = WIZARD_DOG_SCENE.instantiate()
		add_child(gandolfg)
		
		var rect = $CollisionShape2D.shape.get_rect()
		var gandolfg_position: Vector2 = $CollisionShape2D.global_position + Vector2(0, -rect.size.y / 2) 
		gandolfg.setup(gandolfg_position)
	
	var battlefield := InBattle.get_battlefield()
	_player_data = battlefield.get_player_data()
	
	zero_health.connect(_kill_all_dogs, CONNECT_ONE_SHOT)	
	
	_setup_max_health()
	
func _kill_all_dogs() -> void:
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.kill()
	
func _setup_max_health() -> void:
	max_health = 500
	var health_upgrade = Data.passives.get('dog_tower_health')
	if health_upgrade != null:
		max_health = max_health * pow(1.5, health_upgrade['level'])
	health = max_health
	update_health_label()
	
func spawn(dog_id: String) -> BaseDog:
	$SpawnSound.play()
	
	var index = _player_data.team_dog_ids.find(dog_id)
	var dog := _player_data.team_dog_scenes[index].instantiate() as BaseDog
	var dog_level := InBattle.get_dog_level(dog_id)
	var dog_abilities := InBattle.get_dog_abilities(dog_id)
	dog.setup(global_position + Vector2(100, 0), dog_level, dog_abilities)
	
	get_tree().current_scene.add_child(dog)
	
	if Data.dog_info[dog_id].get('spawn_limit', 0) > 0:
		_player_data.dogs_count[dog_id] += 1
		dog.tree_exiting.connect(func(): _player_data.dogs_count[dog_id] -= 1)
	
	dog_spawn.emit(dog)
	return dog

func use_skill(skill_id: String) -> void:
	$SpawnSound.play()
	
	var index = _player_data.team_skill_ids.find(skill_id)
	var skill := _player_data.team_skill_scenes[index].instantiate()
	get_tree().current_scene.add_child(skill)
	skill.setup(Character.Type.DOG)
	
