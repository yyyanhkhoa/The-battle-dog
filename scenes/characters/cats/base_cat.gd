@tool
class_name BaseCat extends Character

@export var reward_money: int = 10

func setup(global_position: Vector2, is_boss: bool = false) -> void:
	super._setup(global_position, is_boss)

func _ready() -> void:
	if Engine.is_editor_hint():
		super._ready()
		return
		
	var battlefield := get_tree().current_scene as Battlefield
	## for debuging purposes
	if battlefield != null:
		var power_scale = battlefield.get_cat_power_scale()
		damage *= power_scale
		health *= power_scale
	
	super._ready()
