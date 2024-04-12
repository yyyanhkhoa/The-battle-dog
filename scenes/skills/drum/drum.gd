extends BaseSkill

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const DRUM_AUDIO: AudioStream = preload("res://resources/sound/Skill/drum.wav")

var knockback_scale: float = 0.5

func setup(skill_user: Character.Type) -> void:
	var level = InBattle.get_skill_level('drum', skill_user)
	knockback_scale = knockback_scale + (level * 0.1) 
	
	var battlefield := get_tree().current_scene as BaseBattlefield
	var effect_space := battlefield.get_effect_space()
	
	var effect: Node2D = EnergyExpand.instantiate()
	effect_space.add_child(effect)
	
	var skill_user_is_dog: bool = skill_user == Character.Type.DOG
	
	if not InBattle.in_p2p_battle:
		var bf := battlefield as Battlefield
		var global_pos = bf.get_dog_tower().get_effect_global_position()
		effect.setup(global_pos, "on_emitter")
	
	else:
		var bf := battlefield as P2PBattlefield
		var global_pos = (
			bf.get_dog_tower_left().get_effect_global_position() if skill_user_is_dog
			else bf.get_dog_tower_right().get_effect_global_position()
		)
		effect.setup(global_pos, "on_emitter")
		
	var targets: Array[Node] = get_tree().get_nodes_in_group(
		"cats" if skill_user == Character.Type.DOG
		else "dogs"
	)
	
	for target in targets:
		target.knockback(knockback_scale)	
		var effect_on_target: Node2D = EnergyExpand.instantiate()
		effect_space.add_child(effect_on_target) 
		effect_on_target.setup(target.get_center_global_position(), "on_subject")

	AudioPlayer.play_in_battle_sfx_once(DRUM_AUDIO, 1.0, true)	
	queue_free()

