@tool
class_name FSM extends Node

## Finite State Machine.
##
## This node uses it's owner as the target 

## notify when about to enter state, use this to modify state data before entering state
signal state_entering (state_name: String, state_data: Dictionary)

## notify when entered a state
signal state_entered (state_name: String)

@export_node_path("FSMState") var initial_state: NodePath = ""

var state: FSMState
var _state_data: Dictionary = {}

func _ready():
	if Engine.is_editor_hint():
		return
		
	state = get_node(initial_state)
	owner.ready.connect(_on_owner_ready, CONNECT_ONE_SHOT)

func get_current_state_name() -> String:
	return state.name
	
func get_current_state() -> FSMState:
	return state
	
func has_state(state_name: String) -> bool:
	return has_node(state_name)
	
func get_current_state_data() -> Dictionary:
	return _state_data

func _on_owner_ready():
	for node in get_children():
		if node is FSMState:
			node.connect("transition", _on_state_transition)
	
	state_entering.emit(initial_state, _state_data)
	update_FSM_process()
	state.enter(_state_data)
	state_entered.emit(initial_state)

func change_state(next_state_name: String, data: Dictionary = {}):
	if next_state_name == get_current_state_name():
		return
	
	_state_data = data
	
	if state.has_method("exit"):
		state.exit()
	
	assert(has_state(next_state_name), "ERROR: state %s do not exist" % next_state_name) 
	state = get_node(next_state_name)
	
	state_entering.emit(next_state_name, _state_data)
	update_FSM_process()
	state.enter(data)
	state_entered.emit(next_state_name)

func update_FSM_process():
	set_physics_process(state.has_method("physics_update"))
	set_process_input(state.has_method("input"))
	set_process(state.has_method("update"))

func _on_state_transition(next_state_name: String, data: Dictionary = {}):
	change_state(next_state_name, data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		state.update(delta)
	
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		state.physics_update(delta)
	
func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		state.input(event)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []

	var children = get_children()
	if children.size() == 0:
		warnings.append("FSM required at least one state to operate")
		
	elif initial_state.is_empty():
		warnings.append("Please select the Initial State")
	
	return warnings
