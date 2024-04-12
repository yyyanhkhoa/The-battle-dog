@tool
extends BaseDog

const BATTER_KNOCKBACK_SCENE: PackedScene = preload("res://scenes/characters/dogs/batter_dog/batter_knockback/batter_knockback.tscn")
const EXPLOSION_SPAWNER_SCENE: PackedScene = preload("res://scenes/characters/dogs/batter_dog/explosion/explosion_spawner.tscn")

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	
	_spawn_drum()
	
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(%Addon, "position:y", 20, 2).as_relative() 
	tween.tween_property(%Addon, "position:y", -20, 2).as_relative() 
	
	if Engine.is_editor_hint():
		return
	
	attack_sprite.frame_changed.connect(func():
		if not InBattle.in_request_mode and attack_sprite.frame == attack_frame:
			_spawn_expolsion()
	)
	
	$FiniteStateMachine.state_entered.connect(_on_state_entered)
	
func _spawn_drum() -> void:
	var knockback = BATTER_KNOCKBACK_SCENE.instantiate()
	InBattle.get_battlefield().add_child(knockback)
	knockback.setup(self)
	
func _on_state_entered(state_path: String):
	if state_path == "MoveState":
		%MoveSound.play()		
	else:
		%MoveSound.stop()	
		
	if state_path == "DieState":
		_spawn_drum()	
		
func _spawn_expolsion() -> void:
	var explosion_spawner = EXPLOSION_SPAWNER_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion_spawner)
	explosion_spawner.setup(get_bottom_global_position(), damage, _dog_level, character_type)
