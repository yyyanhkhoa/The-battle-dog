extends BaseSkill

const UpSprite: PackedScene = preload("res://scenes/skills/power_up/sprite.tscn")
const POWER_UP_SFX: AudioStream = preload("res://resources/sound/Skill/power_up.mp3")

const DURATION: float = 5

func setup(skill_user: Character.Type) -> void:
	AudioPlayer.play_in_battle_sfx_once(POWER_UP_SFX)

	var level := InBattle.get_skill_level('power_up', skill_user)
	var power_scale: float = 1 + (0.1 * level)
	
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	
	var characters := (
		get_tree().get_nodes_in_group("dogs") if skill_user == Character.Type.DOG else
		get_tree().get_nodes_in_group("cats")
	)
		
	for character in characters:
		const SB := Character.SetBehaviour
		const TYPE := Character.MultiplierTypes
		character.set_multiplier(TYPE.SPEED, power_scale, SB.TAKE_HIGHER)
		character.set_multiplier(TYPE.DAMAGE, power_scale, SB.TAKE_HIGHER)
		character.set_multiplier(TYPE.ATTACK_SPEED, power_scale, SB.TAKE_HIGHER)
		character.set_multiplier(TYPE.DAMAGE_TAKEN, 1.0 / power_scale, SB.TAKE_LOWER)
		
		var effect_on_character: Node2D = UpSprite.instantiate()
		effect_space.add_child(effect_on_character) 
		effect_on_character.setup(DURATION, character)
		
	await get_tree().create_timer(DURATION, false).timeout
	
	for character: Character in characters.filter(func(character): return is_instance_valid(character)):
		character.reset_multipliers()
	
	queue_free()

