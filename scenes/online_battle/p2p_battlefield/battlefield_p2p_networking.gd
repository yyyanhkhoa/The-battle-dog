class_name BattlefieldP2PNetworking extends Node
## Base code for battlefield p2p networking. 
## A peer will handle the input requests differently depending whether the peer is a client or server

func _process(delta: float) -> void:	
	push_error("ERROR: _process(delta: float) not implemented")
	return

signal upgrade_efficiency_request_accepted
func request_efficiency_upgrade() -> void:
	push_error("ERROR: request_efficiency_upgrade() not implemented")
	return

signal spawn_request_accepted(dog_id: String)
signal spawn_recharge_time_updated(dog_id: String, time_left: float)
func request_spawn(dog_id: String) -> void:
	push_error("ERROR: request_spawn(dog_id: String) not implemented")
	return

signal skill_request_accepted(skill_id: String)
signal skill_recharge_time_updated(skill_id: String, time_left: float)
func request_skill(skill_id: String) -> void:
	push_error("ERROR: request_skill(skill_id: String) not implemented")
	return
