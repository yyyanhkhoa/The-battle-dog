extends Land

func _ready() -> void:
	var battlefield := InBattle.get_battlefield() as BasicBattlefield
	$TextureRect.texture = load("res://resources/battlefield_themes/%s/land.png" % battlefield.get_theme())
	super._ready()
