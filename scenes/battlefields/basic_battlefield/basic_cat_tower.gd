extends CatTower

func _ready() -> void:
	var battlefield := InBattle.get_battlefield()
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/cat_tower.png" % battlefield.get_theme())
	super._ready()
