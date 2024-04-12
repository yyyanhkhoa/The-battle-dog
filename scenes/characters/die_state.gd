extends FSMState

const FlyingSoul: PackedScene = preload("res://scenes/effects/flying_soul/flying_soul.tscn")
@onready var character: Character = owner

# called when the state is activated
func enter(_data: Dictionary) -> void:
	AudioPlayer.play_in_battle_sfx(character.die_sfx)
	character.queue_free() 
	
	var soul_fx: Node = FlyingSoul.instantiate()
	soul_fx.position = character.position
	soul_fx.z_index = character.z_index
	get_tree().current_scene.add_child(soul_fx)
	soul_fx.setup(character)
	
	var battlefield = get_tree().current_scene as BaseBattlefield
	var _player_data := battlefield.get_player_data()
	
	if character is BaseCat:
		_player_data.fmoney += character.reward_money
