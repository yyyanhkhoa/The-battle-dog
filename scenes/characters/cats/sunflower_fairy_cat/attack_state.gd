extends BaseAirUnitAttackState

@onready var sunflower_cat: SunflowerFairyCat = owner
@onready var danamku_space := InBattle.get_danmaku_space() as DanmakuSpace

var _wait_token: WaitToken

func enter(data: Dictionary) -> void:	
	super(data)
	sunflower_cat.floating_movement_tween.pause()
	
	var pattern := Danmaku.pattern_cirle(sunflower_cat.get_center_global_position(), 0) as DanmakuPatternCircle
	pattern.bullet_num = 20
	var recover_delta: float = 0.0
	for i in range(10):
		AudioPlayer.play_in_battle_sfx(sunflower_cat.attack_hit_sfx)
		
		pattern.start(0, func (_pos: Vector2, angle: float, _rdelta: float, index: int) -> void:
			var color := BulletKits.BulletColor.ORANGE if i % 2 else BulletKits.BulletColor.YELLOW
			var flower_kit := Danmaku.get_bullet_kit(BulletKits.BULLET_ROUND_1, color)
			var bullet := danamku_space.spawn(flower_kit, sunflower_cat)
			bullet.start(func():
				bullet.damage = sunflower_cat.damage
				bullet.velocity_rotation_speed = deg_to_rad(90) * (2 * (index % 2) - 1)
				bullet.velocity = Vector2(2000, 0).rotated(angle)
				bullet.position = %BulletSpawnMarker.global_position + bullet.velocity * recover_delta
				bullet.process(recover_delta)
				
				await Global.wait(0.9)
				if bullet.is_destroyed(): return
				bullet.velocity_rotation_speed = 0
			)
		)
		
		_wait_token = Global.wait_cancelable(0.1, recover_delta) as WaitToken
		recover_delta = await _wait_token.timer.timeout
		if _wait_token.is_canceled(): 
			return
		
	transition.emit("IdleState")

func exit() -> void:
	_wait_token.cancel()
