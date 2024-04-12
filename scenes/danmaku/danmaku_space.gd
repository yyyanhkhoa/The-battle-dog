@tool
class_name DanmakuSpace extends BulletsEnvironment
## a space for bullets to be spawn

const DANMAKU_OUTER_MARGIN: int = 1000
const MAX_POOL_SIZE = 7000

func _init() -> void:
	super._init()
	tree_entering.connect(_config_danmaku_space)
	
func _exit_tree() -> void:
	super._exit_tree()
	if not Engine.is_editor_hint():
		Danmaku.bullet_kits.clear_kits()
		Danmaku.patterns.clear()
		
func _config_danmaku_space(_node: BulletsEnvironment) -> void:
	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	
	var ids: Array[String] = []
	ids.append_array(battlefield.get_player_data().team_dog_ids.filter(func(id): return id != null))
	
	var pool_sizes := _get_dogs_bullet_pool_sizes(ids)
	_add_cats_bullet_pool_sizes(pool_sizes)
	
	register_bullets(pool_sizes)

func _get_dogs_bullet_pool_sizes(dog_ids: Array[String]) -> Dictionary:
	var danmaku_dog_ids = dog_ids.filter(
		func(id): return Data.dog_info[id].has('danmaku_bullets')
	)
	
	var pool_sizes := {}
	for dog_id in danmaku_dog_ids:
		var bullet_pool_sizes = Data.dog_info[dog_id]['danmaku_bullets']
		## abitrary numbers here if spawn_limit is not set
		var spawn_limit = Data.dog_info[dog_id].get('spawn_limit', 3)
		
		for bullet_id in bullet_pool_sizes:
			pool_sizes[bullet_id] = pool_sizes.get(bullet_id, 0) + bullet_pool_sizes[bullet_id] * spawn_limit

	return pool_sizes

func _add_cats_bullet_pool_sizes(pool_sizes: Dictionary) -> void:
	var data: Dictionary = InBattle.get_stage_data()
	var enemy_bullets_arr: Array[Dictionary] = []
	
	var instant_spawn_cat_bullets = data.get("instant_spawns", []).filter(
		func(pattern): return Data.character_info[pattern['id']].has("danmaku_bullets")
	).map(
		func(pattern): return Data.character_info[pattern['id']]["danmaku_bullets"]
	)
	
	var spawn_cat_bullets = data["spawn_patterns"].filter(
		func(pattern): return Data.character_info[pattern['id']].has("danmaku_bullets")
	).map(
		func(pattern):  
			var bullets = Data.character_info[pattern['id']]["danmaku_bullets"].duplicate()
			for bullet_id in bullets:
				## the pool size is increase if cat spawn interval is less than 120 (to account for multiple cats on the battlefield) 
				bullets[bullet_id] *= 20 - round(pattern['interval'] / 6)
			return bullets
	) 

	var bosses_bullets = data.get("bosses", []).filter(
		func(pattern): return Data.character_info[pattern['id']].has("danmaku_bullets")
	).map(
		func(pattern): return Data.character_info[pattern['id']]["danmaku_bullets"]
	)
	
	enemy_bullets_arr.assign(spawn_cat_bullets + bosses_bullets + instant_spawn_cat_bullets)
		
	for enemy_bullets in enemy_bullets_arr:
		for bullet_id in enemy_bullets:
			pool_sizes[bullet_id] = pool_sizes.get(bullet_id, 0) + enemy_bullets[bullet_id]

## register bullets using danmaku_bullets property in character_info
func register_bullets(danmaku_bullets: Dictionary):
	for bullet_code in danmaku_bullets:
		var parts := (bullet_code as String).split(":")
		
		var color: BulletKits.BulletColor
		# unique bullet (no color variations)
		if parts.size() == 1:
			color = BulletKits.BulletColor.UNIQUE
		else:			
			color = BulletKits.COLOR_MAP[parts[1]]
		
		register_bullet(parts[0], color, danmaku_bullets[bullet_code])

## register bullet so that they can be used in battle
func register_bullet(bullet_kit_id: String, color: BulletKits.BulletColor, pool_size: int = 3000) -> void:
	var bullet_kit: DanmakuBulletKit
	if Danmaku.bullet_kits.has_kit(bullet_kit_id, color):
		bullet_kit = Danmaku.bullet_kits.get_kit(bullet_kit_id, color)
	else:
		bullet_kit = Danmaku.bullet_kits.load_kit(bullet_kit_id, color)
	
	InBattle.get_battlefield().ready.connect(func():
		var stage_rect := InBattle.get_battlefield().get_stage_rect()
		stage_rect.position -= Vector2(DANMAKU_OUTER_MARGIN, DANMAKU_OUTER_MARGIN)
		stage_rect.size += Vector2(DANMAKU_OUTER_MARGIN * 2, DANMAKU_OUTER_MARGIN * 2)

		bullet_kit.active_rect = stage_rect
		bullet_kit.collision_layer = 0b1000,
		CONNECT_ONE_SHOT
	)
	
	var index := bullet_kits.find(bullet_kit)
	
	if index == -1:
		index = _get("bullet_types_amount") 
		_set("bullet_types_amount", index + 1)
		
		## pool size min value is 1, so overwrite it first 
		pools_sizes[index] = min(pool_size, MAX_POOL_SIZE)
	else:
		## add to existing pool size
		pools_sizes[index] = min(pools_sizes[index] + pool_size, MAX_POOL_SIZE) 
	
	bullet_kits[index] = bullet_kit
	z_indices[index] = 90

## spawn bullet, returns the bullet controller, remember to check if bullet spawned successfully using the controller
var _bullet_controller_refs: Dictionary = {}
func spawn(
		bullet: DanmakuBulletKit, 
		bullet_owner: Character,
		controller: DanmakuBulletController = DanmakuBulletController.new()
	) -> DanmakuBulletController:
	var id = Bullets.obtain_bullet(bullet)
	controller.setup(bullet, id, bullet_owner.character_type)
	
	if Bullets.is_bullet_valid(id):
		if not _bullet_controller_refs.has(bullet_owner):
			_bullet_controller_refs[bullet_owner] = []
			bullet_owner.tree_exited.connect(_on_owner_dead.bind(bullet_owner))
		
		_bullet_controller_refs[bullet_owner].append(controller)
			
	return controller

func _on_owner_dead(bullet_owner: Character) -> void:
	## godot 4.2 current scene null bs
	if InBattle.get_battlefield() == null:
		return
	
	for controller: DanmakuBulletController in _bullet_controller_refs[bullet_owner]:
		if controller.is_valid():
			controller._handle_owner_dead()
	
	_bullet_controller_refs.erase(bullet_owner)

func destroy_bullets_of(bullet_owner: Character) -> void:
	if not _bullet_controller_refs.has(bullet_owner):
		return
	
	for controller: DanmakuBulletController in _bullet_controller_refs[bullet_owner]:
		if controller.is_valid():
			controller.destroy()
	
	_bullet_controller_refs[bullet_owner].clear()

func get_bullets_of(bullet_owner: Character) -> Array[DanmakuBulletController]:
	return _bullet_controller_refs.get(bullet_owner, []) 
 
## similar to spawn() but bullet is spawned without owner
func spawn_no_owner(
		bullet: DanmakuBulletKit, 
		character_type: Character.Type,
		controller: DanmakuBulletController = DanmakuBulletController.new()
	) -> DanmakuBulletController:
		var id = Bullets.obtain_bullet(bullet)
		controller.setup(bullet, id, character_type)
		return controller
	
func has_bullet(bullet: DanmakuBulletKit) -> bool:
	return bullet_kits.has(bullet)

func get_pool_size(bullet: DanmakuBulletKit) -> int:
	return Bullets.get_pool_size(bullet)
