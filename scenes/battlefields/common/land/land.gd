class_name Land extends StaticBody2D

# This is to avoid characters falling out of the world when knockback to far out of the battle
const OUTER_PADDING = 2000 

func _ready() -> void:
	var battlefield := InBattle.get_battlefield()
	var stage_width = battlefield.get_stage_width()
	
	var shape_extents_x = (stage_width + OUTER_PADDING * 2) / 2
	$CollisionShape2D.shape.extents.x = shape_extents_x
	$CollisionShape2D.position.x = stage_width / 2
	$TextureRect.size.x = stage_width 

func get_size() -> Vector2:
	return $TextureRect.size

## returns the global bottom y position of land
func get_land_bottom_y() -> float:
	return $TextureRect.position.y + $TextureRect.size.y
