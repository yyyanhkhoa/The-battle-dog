extends CharacterMoveState

func physics_update(delta: float) -> void:
	if not %AirUnitDetector.has_overlapping_bodies():
		super(delta)
		return
		
	if character.n_AttackCooldownTimer.is_stopped() and not InBattle.in_request_mode: 
		transition.emit("AttackState")
	else:
		transition.emit("IdleState")
