extends Node2D

const FLY_SPEED: int = 700

const FREQ: int = 7
const AMPLITUDE: int = 40
const TIME_TO_LIVE: int = 4

var time: float = 0
var base_position: Vector2 
 
func setup(target: Character):
	if target is BaseDog:
		add_to_group("dog_flying_souls")
		return
		
	add_to_group("cat_flying_souls")
	var battlefield = get_tree().current_scene as BaseBattlefield
	
	if battlefield is Battlefield and InBattle.get_stage_data().get('special_instruction') == "invert_color":
		$AnimatedSprite.material = load("res://shaders/invert_color/invert_color.material")
		
func _ready() -> void:
	$AnimatedSprite.play("default")
	base_position = position
	
func _process(delta: float) -> void:
	position.y -= FLY_SPEED * delta 
	
	time += delta
	position.x = base_position.x + sin(time * FREQ) * AMPLITUDE
	
	if time >= TIME_TO_LIVE:
		queue_free()
