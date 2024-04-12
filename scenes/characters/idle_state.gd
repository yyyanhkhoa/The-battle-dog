class_name CharacterIdleState extends FSMState

@onready var character: Character = owner

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.n_AnimationPlayer.play("idle")
	
	if character.n_AttackCooldownTimer.is_stopped():
		handle_stop_idle()
	else:
		character.n_AttackCooldownTimer.timeout.connect(handle_stop_idle)
		
		
func handle_stop_idle() -> void:
	var collider = character.n_RayCast2D.get_collider() 
	if collider == null:
		transition.emit("MoveState")
	elif not InBattle.in_request_mode:
		transition.emit("AttackState", {'target': collider })

# called when the state is deactivated
func exit() -> void:
	if character.n_AttackCooldownTimer.timeout.is_connected(handle_stop_idle):
		character.n_AttackCooldownTimer.timeout.disconnect(handle_stop_idle) 
		
func physics_update(delta: float) -> void:
	if character.n_RayCast2D.get_collider() == null:
		transition.emit("MoveState")
	
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		character.move_and_slide()
	else:
		character.velocity.y = 0
	
