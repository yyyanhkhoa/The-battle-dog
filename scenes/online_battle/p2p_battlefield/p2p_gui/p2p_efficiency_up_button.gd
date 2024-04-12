class_name P2PEfficiencyUpButton extends EfficiencyUpButton

var _battlefield: P2PBattlefield

func _ready() -> void:
	super._ready()
	
	_battlefield = get_tree().current_scene as P2PBattlefield
	_battlefield.ready.connect(func():
		var p2p_networking := _battlefield.get_p2p_networking()
		p2p_networking.upgrade_efficiency_request_accepted.connect(_on_upgrade_efficiency_request_accepted)
	)

func _on_upgrade_pressed() -> void:
	_battlefield.get_p2p_networking().request_efficiency_upgrade()

func _on_upgrade_efficiency_request_accepted() -> void:
	$AudioStreamPlayer.play()
	super._update_ui()
