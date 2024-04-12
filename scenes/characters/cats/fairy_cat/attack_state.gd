extends BaseAirUnitAttackState

@onready var fairy_cat: FairyCat = owner 
var cancellation_token: CancellationToken

@onready var danamku_space := InBattle.get_danmaku_space() as DanmakuSpace
@onready var flower_kit := Danmaku.get_bullet_kit(BulletKits.FLOWER)

func enter(data: Dictionary) -> void:
	super(data)
	var pattern := Danmaku.pattern_cirle(fairy_cat.get_center_global_position(), 0) as DanmakuPatternCircle
	pattern.bullet_num = 20
	pattern.angle_offset = randf_range(0, PI * 2)
	pattern.clockwise_direction = Global.rand_bool()
	
	cancellation_token = CancellationToken.new()
	await pattern.start(1, _spawn_bullet, cancellation_token)
	
	if cancellation_token.is_canceled():
		return
		
	transition.emit("IdleState")

func _spawn_bullet(_pos: Vector2, angle: float, _rdelta: float, index: int) -> void:
	var bullet := danamku_space.spawn(flower_kit, fairy_cat)
	bullet.start(func():
		if index % 3 == 0:
			AudioPlayer.play_in_battle_sfx(fairy_cat.attack_hit_sfx)
		
		bullet.damage = fairy_cat.damage
		bullet.position = %BulletSpawnMarker.global_position 
		bullet.velocity_scale = 0.1
		bullet.velocity_rotation_speed = 0
		
		bullet.rotation_speed = PI * 2 * randf_range(1.0 / 3.0, 1.0)
		
		var tween = create_tween().set_loops().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		bullet.velocity = Vector2(500, 0).rotated(angle)
		tween.tween_property(bullet, "velocity_scale", 1.0, 1)
		tween.chain().tween_property(bullet, "velocity_scale", 0.0, 1)
		
		tween.tween_property(bullet, "velocity_rotation_speed", deg_to_rad(360) * (1 * -int(index % 2)), 0.5)
		tween.chain().tween_property(bullet, "velocity_rotation_speed", 0.0, 0.5)
		
		await Global.wait(2.5)
		if bullet.is_destroyed(): return
		
		tween.kill()
		bullet.rotation_speed = 0
		tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(bullet, "rotation", PI, 0.5).as_relative()
		tween.tween_property(bullet, "velocity_scale", 0.1, 1.5)
		tween.tween_property(bullet, "velocity_rotation_speed", 0.0, 1.5)
		await tween.finished
		if bullet.is_destroyed(): return
		
		bullet.velocity_rotation_speed = 0
		bullet.velocity_scale = 1.0
		
		var bullet_velocity = Vector2(100, 0)
		var dogs = get_tree().get_nodes_in_group("dogs")
		if dogs.size() > 0:
			bullet_velocity = bullet_velocity.rotated(bullet.position.angle_to_point(dogs.pick_random().global_position))
		else:
			bullet_velocity = bullet_velocity.rotated(PI * 0.25)
			bullet_velocity.x *= fairy_cat.move_direction
			
		bullet.velocity = bullet_velocity
		bullet.acceleration = bullet.velocity * 20
		
		tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(bullet, "rotation", PI * 3, 1.0)
		await tween.finished
		if bullet.is_destroyed(): return
		
		tween = create_tween().set_loops()
		tween.tween_property(bullet, "rotation", PI * 3, 1.0)
		tween.tween_callback(func(): if bullet.is_destroyed(): tween.kill())
	)

func exit() -> void:
	cancellation_token.cancel()
