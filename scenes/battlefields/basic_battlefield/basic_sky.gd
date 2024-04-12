extends BattlefieldSky

func _ready() -> void:
	super()
	var battlefield := InBattle.get_battlefield() as BasicBattlefield
	texture = load("res://resources/battlefield_themes/%s/sky.png" % battlefield.get_theme())
