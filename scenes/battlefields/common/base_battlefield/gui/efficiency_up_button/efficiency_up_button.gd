class_name EfficiencyUpButton extends TextureButton

var _player_data: BaseBattlefieldPlayerData

func _ready() -> void:
	var battlefield := get_tree().current_scene as BaseBattlefield
	_player_data = battlefield.get_player_data()
	$AnimationPlayer.play("ready")
	$UpgradePriceLabel.text = "%s₵" % _player_data.get_efficiency_upgrade_price()
	pressed.connect(_on_upgrade_pressed)
	
	var index = _player_data.team_store_ids.find("full_money")
	if Data.store.has('full_money') and Data.store['full_money']['amount'] > 0:
		upgrade_max_level()
	

func _process(delta: float) -> void:
	disabled = not can_afford_efficiency_upgrade()
	
	if _player_data.get_efficiency_level() == _player_data.MAX_EFFICIENCY_LEVEL:
		$Background.frame = 0
	else:
		$Background.frame = 1 if disabled else 0
		
func can_afford_efficiency_upgrade() -> bool:
	return _player_data.get_money_int() >= _player_data.get_efficiency_upgrade_price()
	
func _on_upgrade_pressed() -> void:
	if _player_data.get_efficiency_level() < _player_data.MAX_EFFICIENCY_LEVEL:
		$AudioStreamPlayer.play()
		_player_data.fmoney -= _player_data.get_efficiency_upgrade_price()
		_player_data.increase_efficiency_level()
		_update_ui()

func upgrade_max_level():
	while _player_data.get_efficiency_level() < _player_data.MAX_EFFICIENCY_LEVEL:
		_player_data.fmoney -= _player_data.get_efficiency_upgrade_price()
		_player_data.increase_efficiency_level()
		_update_ui()

func _update_ui() -> void:
	$EfficiencyLevelLabel.text = "LV.%s" % _player_data.get_efficiency_level()
		
	if _player_data.get_efficiency_level() == _player_data.MAX_EFFICIENCY_LEVEL:
		$UpgradePriceLabel.text = "MAX"
	else:
		$UpgradePriceLabel.text = "%s₵" % _player_data.get_efficiency_upgrade_price()
