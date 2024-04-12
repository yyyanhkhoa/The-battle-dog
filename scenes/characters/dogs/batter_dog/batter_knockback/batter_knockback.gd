extends Node

const ENERGY_EXPAND_SCENE: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const DRUM_SOUND: AudioStream = preload("res://resources/sound/Skill/drum.wav")

func setup(emitter: BaseDog) -> void:
	var effect: Node2D = ENERGY_EXPAND_SCENE.instantiate()
	var effect_space: = InBattle.get_battlefield().get_effect_space()
	
	effect_space.add_child(effect)
	effect.setup(emitter.get_center_global_position(), "on_emitter")
	
	var enemies: Array[Node]
	if emitter.character_type == Character.Type.DOG:
		enemies = get_tree().get_nodes_in_group("cats")
	else:
		# in pvp battle, Batter Dog that are spawn on the right side dog tower
		# will act as "Cat" character type
		enemies = get_tree().get_nodes_in_group("dogs")
	
	AudioPlayer.play_in_battle_sfx_once(DRUM_SOUND, 1.0, true)
	
	for enemy in enemies:
		enemy.knockback()	
		var effect_on_enemy: Node2D = ENERGY_EXPAND_SCENE.instantiate()
		effect_space.add_child(effect_on_enemy) 
		effect_on_enemy.setup(enemy.global_position, "on_subject")
		
