class_name P2PBattleGUI extends CanvasLayer

@onready var spawn_buttons: Control = %P2PSpawnButtons
@onready var money_label: Label = $MoneyLabel
@onready var skill_buttons: Control = %P2PSkillButtons
@onready var efficiency_up_button: TextureButton = $EfficiencyUpButton
@onready var camera_control_buttons: CameraControlButtons = $CameraControlButtons

signal surrendered

var _player_data: P2PBattlefieldPlayerData

func setup(dog_tower: P2PDogTower, player_data: P2PBattlefieldPlayerData):
	%P2PSpawnButtons.setup(dog_tower, player_data)
	%P2PSkillButtons.setup(dog_tower, player_data)
	_player_data = player_data
	
func _ready() -> void:
	$SurrenderButton.pressed.connect(_on_surrender_button_pressed)
	$SurrenderBattlePopup.surrendered.connect(
		func(): surrendered.emit()
	)
	
func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [_player_data.get_money_int(), _player_data.get_wallet_capacity()]	

func _on_surrender_button_pressed() -> void:
	$SurrenderBattlePopup.show()
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
