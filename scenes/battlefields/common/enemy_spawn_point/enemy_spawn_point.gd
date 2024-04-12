class_name EnemySpawnPoint extends Marker2D

const BOSS_SHADER: ShaderMaterial = preload("res://shaders/outline_glow/outline_glow.material")
const ENERY_EXPAND: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const MAX_RANDOM_DELAY: float = 2.5

signal cat_spawn (cat: Character)
signal boss_appeared

@export var knockback_energy_expand_point: Marker2D

var cats: Dictionary

var cats_count: Dictionary
var bosses_queue: Array
var spawn_timers: Array[Timer]

var _stage_data: Dictionary

## number of bosses currently on battle
var alive_boss_count: int = 0

func _ready() -> void:
	if knockback_energy_expand_point == null:
		knockback_energy_expand_point = self

func _enter_tree() -> void:
	_stage_data = InBattle.get_stage_data()
	var instant_spawns: Array = _stage_data.get('instant_spawns', [])
	var spawn_patterns: Array = _stage_data.get('spawn_patterns', [])
	var bosses: Array = _stage_data.get('bosses', [])
	
	var instant_spawn_cat_ids := instant_spawns.map(func(s): return s['id'])
	var spawn_cat_ids := spawn_patterns.map(func(s): return s['id'])
	var boss_cat_ids := bosses.map(func(s): return s['id'])
	var cat_ids := spawn_cat_ids + boss_cat_ids + instant_spawn_cat_ids
	cats = _load_cats(cat_ids) 
	
	for cat_id in cat_ids:
		cats_count[cat_id] = 0
	
	bosses.sort_custom(func(a, b):
		return a['health_at'] <= b['health_at']
	)
	bosses_queue = bosses

	for pattern in spawn_patterns:
		_setup_spawn_pattern(pattern)

	await InBattle.get_battlefield().ready
	_spawn_instate_spawn_cats(instant_spawns)

			
func _load_cats(cat_ids: Array) -> Dictionary:
	var cats := {}
	for cat_id in cat_ids:
		if cats.has(cat_id):
			continue
			
		var is_dog: bool = (cat_id as String).ends_with('dog')
			
		if is_dog:
			cats[cat_id] = load("res://scenes/characters/dogs/%s/%s.tscn" % [cat_id, cat_id])
		else:
			cats[cat_id] = load("res://scenes/characters/cats/%s/%s.tscn" % [cat_id, cat_id])
			
	return cats


func _spawn_instate_spawn_cats(instant_spawns: Array) -> void:
	var battlefield = InBattle.get_battlefield() as BaseBattlefield
	for spawn_data in instant_spawns:	
		var cat_id: String = spawn_data['id']
		spawn(cat_id, spawn_data, func(cat: Character):
			var rand_x = randf_range(battlefield.TOWER_MARGIN, battlefield.get_stage_width()) + 1000
			
			# position can be a number (for position.x) or an array (for position.x and position.y)
			var data_pos = spawn_data.get('position', rand_x)
			var pos: Vector2 
			if typeof(data_pos) == TYPE_ARRAY:
				pos = Vector2(data_pos[0], data_pos[1])
			else:
				pos = Vector2(data_pos, 0)
			
			if cat is AirUnitCat:
				cat.change_target_overtime = false
				var stage_rect := battlefield.get_stage_rect()
				cat.global_position = pos
				if typeof(data_pos) != TYPE_ARRAY:
					var rand_y = randf_range(stage_rect.position.y + cat.movement_radius, -cat.movement_radius - 300)
					cat.global_position.y = rand_y
				
			else:
				cat.global_position = pos
				
		)

func _setup_spawn_pattern(pattern: Dictionary) -> void:
	var timer = Timer.new()
	spawn_timers.append(timer)
	add_child(timer)
	timer.one_shot = false
	
	var delay: float= pattern.get('delay', 0.0)
	var spawn_duration: float = pattern.get('interval', 5.0)
	var spawn_type: String = pattern.get('spawn_type', "default")		
	var limit: int = pattern.get('limit', -1)
	
	var spawn_cat := func():
		var cat_id: String = pattern['id']
		if limit < 0 or cats_count[cat_id] < limit:
			spawn(cat_id, pattern)
			
		timer.wait_time = spawn_duration + randf() * MAX_RANDOM_DELAY
	
	var start_timer: Callable
	var start_timer_no_delay: Callable
	
	if pattern.get('spawn_type') == 'once':
		timer.one_shot = true
		
		start_timer_no_delay = func():
			spawn_cat.call()
			timer.queue_free()
			spawn_timers.erase(timer)
	else:
		start_timer_no_delay = func():
			spawn_cat.call()
			timer.start()
			timer.timeout.connect(spawn_cat)
	
	if delay <= 0:
		start_timer = start_timer_no_delay
	else:
		start_timer = func():
			timer.start(delay)
			timer.timeout.connect(start_timer_no_delay, CONNECT_ONE_SHOT)

	if pattern.get('when') == 'boss_spawned':
		boss_appeared.connect(start_timer)
	else:
		start_timer.call_deferred()
	

func spawn(cat_id: String, data: Dictionary = {}, pre_ready_callback := Callable()) -> Character:
	var cat: Character = cats[cat_id].instantiate()
	
	if _stage_data.has('special_instruction'):
		cat.ready.connect(_apply_special_instruction.bind(cat))
		
	_set_cat_props(cat, data.get('props', {}))
	
	if cat is BaseCat:
		cat.setup(global_position)
	elif cat is BaseDog:
		var dog_level: int = data.get('dog_level', 1)
		var dog_abilities: Array[String] = []
		dog_abilities.assign(data.get('dog_abilities', []))
		cat.setup(global_position, dog_level, dog_abilities)
	
	if pre_ready_callback.is_valid():
		pre_ready_callback.call(cat)
	
	InBattle.get_battlefield().add_child(cat)
	
	cat_spawn.emit(cat)
	
	cats_count[cat_id] += 1
	cat.tree_exiting.connect(func(): cats_count[cat_id] -= 1)
	return cat
	
func spawn_boss(data: Dictionary) -> void:
	var cat: Character = cats[data['id']].instantiate()

	if cat is BaseCat:
		cat.setup(global_position, true) 
	elif cat is BaseDog:
		var dog_level: int = data.get('dog_level', 1)
		var dog_abilities: Array[String] = []
		dog_abilities.assign(data.get('dog_abilities', []))
		cat.setup(global_position, dog_level, dog_abilities, Character.Type.CAT, true)
		
	if data.get('effect') != 'none':
		_add_boss_shader(cat)
	
	_set_cat_props(cat, data.get('props', {}))
	_set_cat_buffs(cat, data.get('buffs', []))
		
	InBattle.get_battlefield().add_child(cat)
	alive_boss_count += 1
	cat.tree_exited.connect(func(): alive_boss_count -= 1)
	
	boss_appeared.emit()
	knockback_dogs()

func _set_cat_props(cat: Character, props: Dictionary) -> void:
	for prop_name in props:
		var prop_val = cat.get(prop_name) 
		if prop_val != null:
			var prop_new_value = props[prop_name].get("value")
			if prop_new_value != null:
				cat.set(prop_name, prop_new_value)
			
			var prop_scale = props[prop_name].get("scale")
			if prop_scale != null:
				cat.set(prop_name, cat.get(prop_name) * prop_scale)

## deprecated feature, use props instead 
func _set_cat_buffs(cat: Character, buffs: Array) -> void:
	for buff in buffs:
		var prop_name = buff["name"]
		var prop_val = cat.get(prop_name) 
		if prop_val != null:
			var prop_new_value = buff.get("value")
			if prop_new_value:
				cat.set(prop_name, prop_new_value)
			
			var prop_scale = buff.get("scale")
			if prop_scale:
				cat.set(prop_name, cat.get(prop_name) * prop_scale)

func _add_boss_shader(cat: Character) -> void:
	await cat.ready
	var old_animtion_node := cat.n_CharacterAnimation
	var canvas_group := CanvasGroup.new() 
	canvas_group.name = old_animtion_node.name
	canvas_group.scale = old_animtion_node.scale
	canvas_group.modulate = old_animtion_node.modulate
	canvas_group.material = BOSS_SHADER
	old_animtion_node.replace_by(canvas_group)
	
	cat.n_CharacterAnimation = canvas_group
	
func _process(delta: float) -> void:
	if alive_boss_count > 0:
		BOSS_SHADER.set_shader_parameter("zoom", get_viewport_transform().get_scale().y)
	
func _apply_special_instruction(cat: Character):
	if _stage_data['special_instruction'] == "invert_color":
		cat.n_Sprite2D.material = load("res://shaders/invert_color/invert_color.material")

func knockback_dogs(knockback_scale: float = 2.5) -> void:
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	var effect := ENERY_EXPAND.instantiate()
	
	effect.setup(knockback_energy_expand_point.global_position, "on_emitter")
	InBattle.get_battlefield().get_effect_space().add_child(effect)
	
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.knockback(knockback_scale)
