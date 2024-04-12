class_name BattlefieldSky extends TextureRect

func _ready() -> void:
	position = Vector2(0, -size.y)
	size.x = InBattle.get_battlefield().get_stage_width()
