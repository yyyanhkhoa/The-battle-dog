class_name DanmakuBulletController extends RefCounted

signal body_enter(body: Node2D)

var _native_bullet_id
var _bullet: DanmakuBulletKit
var _danmaku_space: DanmakuSpace

var character_type: Character.Type

var damage: int

func is_valid() -> bool:
	return Bullets.is_bullet_valid(_native_bullet_id)

func is_destroyed() -> bool:
	return not is_valid()

var position: Vector2:
	get: return _get_prop_or_default("transform", Transform2D.IDENTITY).origin
	set(value): 
		if is_valid():
			var transform: Transform2D = Bullets.get_bullet_property(_native_bullet_id, "transform")
			transform.origin = value
			Bullets.set_bullet_property(_native_bullet_id, "transform", transform)
		
var rotation: float:
	get: return _get_prop_or_default("transform", Transform2D.IDENTITY).get_rotation()
	set(value): 
		if is_valid():
			var transform: Transform2D = Bullets.get_bullet_property(_native_bullet_id, "transform")
			Bullets.set_bullet_property(
					_native_bullet_id, "transform", Transform2D(value, position)
			)
		
var velocity: Vector2:
	get: return _get_prop_or_default("velocity", Vector2.ZERO)
	set(value): 
		if is_valid():
			Bullets.set_bullet_property(_native_bullet_id, "velocity", value)
			
var velocity_scale: float:
	get: return _get_prop_or_default("velocity_scale", 0.0)
	set(value): 
		if is_valid():
			Bullets.set_bullet_property(_native_bullet_id, "velocity_scale", value)
			
var acceleration: Vector2:
	get: return _get_prop_or_default("acceleration", Vector2.ZERO)
	set(value):
		if is_valid():
			Bullets.set_bullet_property(_native_bullet_id, "acceleration", value)

## rads per second
var velocity_rotation_speed: float:
	get: return _get_prop_or_default("velocity_rotation_speed", 0.0)
	set(value):
		if is_valid():
			Bullets.set_bullet_property(_native_bullet_id, "velocity_rotation_speed", value)

var rotation_speed: float:
	get: return _get_prop_or_default("rotation_speed", 0.0)
	set(value):
		if is_valid():
			Bullets.set_bullet_property(_native_bullet_id, "rotation_speed", value)

	
func _get_prop_or_default(property: String, default: Variant) -> Variant:
	return Bullets.get_bullet_property(_native_bullet_id, property) if is_valid() else default

func setup(bullet: DanmakuBulletKit, native_bullet_id, character_type: Character.Type) -> void:
	damage = bullet.damage
	_bullet = bullet
	_native_bullet_id = native_bullet_id
	self.character_type = character_type
	
	Bullets.set_bullet_property(_native_bullet_id, "data", self)
	body_enter.connect(_handle_body_entered)
	
## start controlling the bullet if bullet is valid [br]
## you should controll your bullet inside this start method to avoid 
## bullet not valid error (danmaku space ran out of avaiable bullets to spawn)
func start(callable: Callable) -> void:
	if is_valid():
		await callable.call()

## use this to manually process the bullet		
func process(delta: float) -> void:
	if not is_zero_approx(delta):
		Bullets.process_bullet(_native_bullet_id, delta)

func _handle_body_entered(body: Node2D):
	body.take_damage(damage)
	InBattle.add_hit_effect(position)
	AudioPlayer.play_in_battle_sfx(_bullet.hit_sfx)
	Bullets.call_deferred("release_bullet", _native_bullet_id)

## this will be called by DanmakuSpace when the owner of the bullet is dead 
func _handle_owner_dead() -> void:
	destroy()
	
## destroy the bullet on the spot
func destroy():
	InBattle.add_hit_effect(position)
	Bullets.call_deferred("release_bullet", _native_bullet_id)	
