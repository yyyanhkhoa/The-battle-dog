extends Node

## manage bullet kits, will be used by DanmakuSpace to load in bullets
var bullet_kits :=  BulletKits.new()

## manage patterns, will be clear when DanmakuSpace exit the scene tree 
var patterns: Array[DanmakuPattern] = []

## returns a circular pattern, remeber to queue free it when done
func pattern_cirle(origin: Vector2, radius: float) -> DanmakuPatternCircle:
	var pattern := DanmakuPatternCircle.new()
	pattern.origin = origin
	pattern.radius = radius
	patterns.append(pattern)
	return pattern 

func _physics_process(delta: float) -> void:
	## iterate backwards to avoid 
	for i in range(patterns.size() - 1, -1, -1):
		var pattern: DanmakuPattern = patterns[i]
		if pattern.is_starting():
			pattern._process(delta)
		elif pattern.get_reference_count() <= 2 && pattern.finished.get_connections().is_empty():
			patterns.erase(pattern)

func get_bullet_kit(bullet_kit_resource_path: String, color: BulletKits.BulletColor = BulletKits.BulletColor.UNIQUE) -> DanmakuBulletKit:
	return bullet_kits.get_kit(bullet_kit_resource_path, color)	
