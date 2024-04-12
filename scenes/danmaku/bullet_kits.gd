class_name BulletKits extends RefCounted

# kit with full color variantions
const BULLET_1: String = "bullet1"
const BULLET_ROUND_1: String = "bullet_round1"

# kit with partial color variations
const OFUDA: String = "ofuda"

# kit with unique color
const FLOWER: String = "flower"

enum BulletColor { GRAY, PINK, RED, ORANGE, YELLOW, GREEN, TURQUOISE, BLUE, PURPLE, UNIQUE }

## all bullet colors (exclude BulletColor.UNIQUE)
const BULLET_COLORS := [
	BulletColor.GRAY, BulletColor.PINK, BulletColor.RED,
 	BulletColor.ORANGE, BulletColor.YELLOW, BulletColor.GREEN,
	BulletColor.TURQUOISE, BulletColor.BLUE, BulletColor.PURPLE
]

const COLOR_MAP := {
	"gray": BulletColor.GRAY, "pink": BulletColor.PINK, "red": BulletColor.RED,
	"orange": BulletColor.ORANGE, "yellow": BulletColor.YELLOW, "green": BulletColor.GREEN,
	"turquoise": BulletColor.TURQUOISE, "blue": BulletColor.BLUE, "purple": BulletColor.PURPLE,
	"unique": BulletColor.UNIQUE
}

var _unique_kits := {}
var _kits_color_map := {}

func load_kit(bullet_kit_id: String, color: BulletColor = BulletColor.UNIQUE) -> DanmakuBulletKit:
	if not _unique_kits.has(bullet_kit_id):
		_unique_kits[bullet_kit_id] = load("res://scenes/danmaku/bullets/%s/%s.tres" % [bullet_kit_id, bullet_kit_id])
	
	if not _kits_color_map.has(bullet_kit_id):
		_kits_color_map[bullet_kit_id] = {}
	
	var kit: DanmakuBulletKit
	
	if color == BulletColor.UNIQUE:
		kit = _unique_kits[bullet_kit_id]
	else:
		kit = _unique_kits[bullet_kit_id].duplicate()
		var material := kit.material.duplicate() as ShaderMaterial
		material.set_shader_parameter("target_frame", color)
		
		kit.material = material
		
	kit.resource_name = "%s:%s" % [bullet_kit_id, COLOR_MAP.find_key(color)]
	_kits_color_map[bullet_kit_id][color] = kit
	return kit

func clear_kits() -> void:
	_unique_kits.clear()
	_kits_color_map.clear()

func get_kit(bullet_kit_id: String, color: BulletColor) -> DanmakuBulletKit:
	return _kits_color_map[bullet_kit_id][color]
	
func has_kit(bullet_kit_id: String, color: BulletColor) -> bool:
	return _kits_color_map.has(bullet_kit_id) and _kits_color_map[bullet_kit_id].has(color)
