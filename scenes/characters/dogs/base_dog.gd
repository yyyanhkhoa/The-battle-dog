@tool
class_name BaseDog extends Character

# id used to retrive save infomation of a dog character
@export var name_id: String 
# Kiem tra xem nhan vat co dang bi dieu khien hay khong
var is_user_control 

var _dog_level: int
func get_dog_level() -> int: return _dog_level

var _abilities: Array[String]
func has_ability(ability: String) -> bool: 
	if InBattle.in_p2p_battle:
		return true
	else:
		return _abilities.has(ability)

## p2p variables
var _sync_data: Dictionary

func setup(
		global_position: Vector2,
		dog_level: int,
		abilities: Array[String],
		character_type: Character.Type = Character.Type.DOG,
		is_boss: bool = false
	) -> void:
		
	self.character_type = character_type
	_setup(global_position, is_boss)
	
	if not Global.is_host_OS_web_mobile() and not InBattle.in_p2p_battle and character_type != Character.Type.CAT:
		$Arrow.position =  Vector2(20,0)
		$Arrow.position.y = -round($CollisionShape2D.shape.extents.y * 2)
		input_event.connect(_on_input_event)
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
	
	_abilities = abilities
	_dog_level = dog_level
	var scale := 1.0 + ((dog_level - 1) * 2.0 / 9.0)
	damage *= scale  
	health *= scale
	
	if character_type == Character.Type.CAT:
		ready.connect(func():
			n_CharacterAnimation.scale.x = -1,
			CONNECT_ONE_SHOT
		)
		
	is_user_control = false
	
	_sync_data = { 
		"object_type": P2PObjectSync.ObjectType.DOG,
		"instance_id": get_instance_id(),
		"dog_id": name_id,
		"character_type": character_type,
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)

func take_damage(ammount: int) -> void:
	# allow take damage if is in single player mode or if is server
	if InBattle.in_request_mode:
		return
		
	super.take_damage(ammount)
	if health <= 0:
		remove_from_group("p2p_sync")

func _on_mouse_entered():
	if is_user_control == false :
		$Arrow.show()
		$Arrow.tint_under = Color.WHITE

func _on_mouse_exited():
	if is_user_control == false :
		$Arrow.hide()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed :		
		set_control()

func set_control() :
	if is_user_control == false : # player can control dog
		var dogs: Array[Node] = get_tree().get_nodes_in_group("dogs")
		for dog in dogs:
			print(dog)
			$Arrow.tint_under = Color.RED
			dog.is_user_control = false			
			dog.get_node("Arrow").hide()		
			dog.get_node("FiniteStateMachine").change_state("MoveState")
		is_user_control = true
		$Arrow.show()		
		$FiniteStateMachine.change_state("UserMoveState")
		
	elif is_user_control == true  : # set dog to auto fight
		$Arrow.hide()
		is_user_control = false
		$FiniteStateMachine.change_state("MoveState")

func _process(delta):
	if not Engine.is_editor_hint():
		if $AttackCooldownTimer.is_stopped() == false :
			$Arrow.value = float(($AttackCooldownTimer.wait_time - $AttackCooldownTimer.time_left) * (float(100/$AttackCooldownTimer.wait_time)))		
		else :
			$Arrow.value = 0

func get_p2p_sync_data() -> Dictionary:
	_sync_data["position"] = position
	_sync_data["health"] = health
	_sync_data["multipliers"] = _multipliers
	_sync_data["FSM"] = {
		'state': get_FSM().get_current_state_name(),
		'data': get_FSM().get_current_state_data()
	}
	
	return _sync_data

## dogs are create from dog tower which do not need to be setup manually
func p2p_setup(_sync_data: Dictionary) -> void:
	return

## prevent multiple attacks if client attack state is completed faster than server
var _synced_attack: bool = false

func p2p_sync(sync_data: Dictionary) -> void:
	position = sync_data['position']
	
	if health != sync_data['health']:
		health = sync_data['health']
		if is_past_knockback_health():
			update_next_knockback_health()
					
		if Debug.is_debug_mode():
			queue_redraw()
	
	var multipliers = sync_data['multipliers']
	for type in multipliers:
		set_multiplier(type, multipliers[type], SetBehaviour.OVERWRITE)
	
	var fsm_sync_data = sync_data['FSM']
	var fsm = get_FSM()

	if fsm_sync_data['state'] != "AttackState":
		_synced_attack = false

	if fsm_sync_data['state'] == "AttackState":
		if _synced_attack:
			return
			
		fsm.change_state(fsm_sync_data['state'], fsm_sync_data['data'])
		_synced_attack = true
		
	fsm.change_state(fsm_sync_data['state'], fsm_sync_data['data'])
		
func p2p_remove() -> void:
	health = 0
	knockback()
