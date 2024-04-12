class_name BattleGUI extends CanvasLayer

@onready var spawn_buttons: Control = %SpawnButtons
@onready var money_label: Label = $MoneyLabel
@onready var skill_buttons: Control = %SkillButtons
@onready var efficiency_up_button: TextureButton = $EfficiencyUpButton
@onready var pause_button: TextureButton = $PauseButton
@onready var game_speed_button: GameSpeedButton = $GameSpeedButton
@onready var camera_control_buttons: CameraControlButtons = $CameraControlButtons

var _player_data: BaseBattlefieldPlayerData

func setup(dog_tower: DogTower, player_data: BaseBattlefieldPlayerData):
	%SpawnButtons.setup(dog_tower, player_data)
	%SkillButtons.setup(dog_tower, player_data)
	_player_data = player_data
	
func _ready() -> void:
	$PauseButton.pressed.connect(_on_paused)
	
func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [_player_data.get_money_int(), _player_data.get_wallet_capacity()]	

func _on_paused() -> void:
	$PauseMenu.show()
	get_tree().paused = true
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
