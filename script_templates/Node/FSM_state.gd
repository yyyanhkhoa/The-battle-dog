extends FSMState

@onready var character: Character = owner

# called when the state is activated
func enter(data: Dictionary) -> void:
	pass 

# (optional) called when the state is deactivated
func exit() -> void:
	pass 
		
# (optional) equivalent to _process but only called when the state is active
func update(delta: float) -> void:
	pass 
	
# (optional) equivalent to _physics_process but only called when the state is active
func physics_update(delta: float) -> void:
	pass 

# (optional) equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
	
