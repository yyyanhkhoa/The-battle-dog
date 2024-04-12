class_name OnlineLand extends Land

func _ready() -> void:
	$TextureRect.texture = load("res://resources/battlefield_themes/%s/land.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	var stage_width = int(Steam.getLobbyData(SteamUser.lobby_id, "stage_width"))
	var stage_width_with_margin = stage_width + (BaseBattlefield.TOWER_MARGIN * 2)
	var shape_extents_x = (stage_width_with_margin + OUTER_PADDING * 2) / 2
	$CollisionShape2D.shape.extents.x = shape_extents_x
	$CollisionShape2D.position.x = stage_width_with_margin / 2
	$TextureRect.size.x = stage_width_with_margin
