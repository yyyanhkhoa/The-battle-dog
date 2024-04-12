@tool
class_name TitanDog extends Character

const RUMBLING_SFX: AudioStream = preload("res://scenes/stores/titan_dog/rumbling.mp3")

# id used to retrive save infomation of a dog character
@export var name_id: String 
var is_user_control = 0
var level 

func store_setup(dog_tower: DogTower, player_data: BaseBattlefieldPlayerData):
	Data.store["titan_dog"].amount -= 1
	level = Data.selected_stage 
	setup(dog_tower.global_position + Vector2(1000,0),1)

func setup(
		global_position: Vector2,
		dog_level: int,
		character_type: Character.Type = Character.Type.DOG,
		is_boss: bool = false
	) -> void:
	
	$FiniteStateMachine.change_state("MoveState")
	self.character_type = character_type
	_setup(global_position, is_boss)
	damage = 10 + 5 * level  
	health = health + health * level
	
	velocity.x = speed * move_direction 
	AudioPlayer.play_in_battle_sfx(RUMBLING_SFX, 1.0, true)

func take_damage(ammount: int) -> void:
	super.take_damage(ammount)
	if health <= 0:
		$FiniteStateMachine.change_state("DieState")

func _exit_tree():
	AudioPlayer.remove_in_battle_sfx(RUMBLING_SFX)
	
func knockback(scale: float = 1):
	pass

func _on_attack_cooldown_timer_timeout():
	var characters := get_tree().get_nodes_in_group("cats")
	for character: Character in characters:
		character.take_damage(damage)
		InBattle.add_hit_effect(character.get_bottom_global_position())

	for i in range(5):
		InBattle.add_hit_effect(get_bottom_global_position() + Vector2(randf_range(i * 50, (i + 1) * 50), 0))
		InBattle.add_hit_effect(get_bottom_global_position() - Vector2(randf_range(i * 50, (i + 1) * 50), 0))
	

