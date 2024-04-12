extends CharacterIdleState

func physics_update(delta: float) -> void:
	if character.n_RayCast2D.get_collider() == null and not %AirUnitDetector.has_overlapping_bodies():
		transition.emit("MoveState")
	
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		character.move_and_slide()
	else:
		character.velocity.y = 0

func handle_stop_idle() -> void:
	var collider = character.n_RayCast2D.get_collider() 
	if not InBattle.in_request_mode and (collider != null or %AirUnitDetector.has_overlapping_bodies()):
		transition.emit("AttackState", {'target': collider })
	else:
		transition.emit("MoveState")
