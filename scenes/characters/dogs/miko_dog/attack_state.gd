extends FSMState

const YIN_YANG_ORB_SCENE: PackedScene = preload("res://scenes/characters/dogs/miko_dog/yin_yang_orb/yin_yang_orb.tscn")
const OFUDA_SOUND_1: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_tan00.wav")
const OFUDA_SOUND_2: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_tan01.wav")
const OFUDA_SOUND_3: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_tan02.wav")
const CHARGINUP_SOUND: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_ch02.wav")

@onready var miko_dog: MikoDog = owner

var ofuda_red := Danmaku.get_bullet_kit(BulletKits.OFUDA, BulletKits.BulletColor.RED)	
var ofuda_gray := Danmaku.get_bullet_kit(BulletKits.OFUDA, BulletKits.BulletColor.GRAY)	

var battlefield: BaseBattlefield
var danmaku_space: DanmakuSpace
var attack_count: int = 0

var _twwen: Tween
var _original_position: Vector2
var _attacked := false

var _cancellation_token := CancellationToken.new()

func _init() -> void:
	danmaku_space = InBattle.get_battlefield().get_danmaku_space()
		
# called when the state is activated
func enter(data: Dictionary) -> void:
	_attacked = false
	_cancellation_token = CancellationToken.new()
	var fly_up_vector := Vector2(500  * miko_dog.move_direction, -1000)
	var fly_position = miko_dog.get_center_global_position() + fly_up_vector
	
	battlefield = InBattle.get_battlefield()
	miko_dog.n_AnimationPlayer.play("fly")
	
	var target_position: Vector2 = data['attack_point']
	var direction: Vector2 = (target_position - fly_position).normalized()
	$Patterns.rotation = direction.angle()
	
	_original_position = miko_dog.position
	_twwen = create_tween()
	
	_twwen.set_parallel(true)
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_IN_OUT)
	_twwen.tween_property(miko_dog, "position", fly_up_vector, 1).as_relative()
	
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_OUT)
	_twwen.tween_property(miko_dog, "rotation", deg_to_rad(15), 1)
	
	await _twwen.finished
	if _cancellation_token.is_canceled(): return
	
	AudioPlayer.play_in_battle_sfx(CHARGINUP_SOUND)
	
	miko_dog.n_AnimationPlayer.play("pre_attack")
	miko_dog.n_AnimationPlayer.queue("attack")

	await Global.wait(1.1)
	if _cancellation_token.is_canceled(): return
	
	_attacked = true
	await _attack(direction)
	if _cancellation_token.is_canceled(): return
	
	_twwen = create_tween()
	_twwen.set_parallel(true)
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_IN_OUT)
	_twwen.tween_property(miko_dog, "position", _original_position, 1)
	
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_OUT)
	_twwen.tween_property(miko_dog, "rotation", 0, 0.5)
	
	miko_dog.n_AnimationPlayer.play_backwards("pre_attack")
	miko_dog.n_AnimationPlayer.queue("fly")
	
	await _twwen.finished
	if _cancellation_token.is_canceled(): return
		
	miko_dog.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
	
func _attack(direction: Vector2) -> void:	
	var total_wait_time: int = 1
	var dog_level := (miko_dog as BaseDog).get_dog_level()
	var straight_bullets_num = 10 + dog_level
	const MAIN_PATTERN_SPEED: float = 2000
	
	if miko_dog.has_ability('yin_yang_orb'):
		_spawn_yin_yang_orb(dog_level, Vector2(300, 0))

	_pattern_straight_line(direction, MAIN_PATTERN_SPEED, straight_bullets_num, ofuda_red)
	
	if dog_level >= 2:
		_pattern_straight_line(
			direction.rotated(deg_to_rad(5)), MAIN_PATTERN_SPEED, straight_bullets_num, ofuda_gray
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-5)), MAIN_PATTERN_SPEED, straight_bullets_num, ofuda_gray
		)
		
	if dog_level >= 3:
		await Global.wait(0.25)
		if _cancellation_token.is_canceled(): return
		
		_pattern_straight_line(
			direction.rotated(deg_to_rad(15)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, ofuda_red
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-15)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, ofuda_red
		)
		
	if dog_level >= 4:
		const SPEED: int = 1000
		const ROTATION: int = 20
		_pattern_straight_line(
			direction.rotated(deg_to_rad(10)), SPEED, straight_bullets_num, ofuda_gray, -ROTATION
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-10)), SPEED, straight_bullets_num, ofuda_gray, ROTATION
		)
		
	if miko_dog.has_ability('circular_ofudas'):
		var bullet_num: int = 4 * dog_level
		var loop: int = dog_level - 4
		const DURATION: float = 0.25
		const ROTATION: int = deg_to_rad(10)
		const SPEED: int = 1000
		_pattern_path(%Path1, DURATION, bullet_num, loop, ROTATION, SPEED, OFUDA_SOUND_1)
		_pattern_path(%Path2, DURATION, bullet_num, loop, -ROTATION, SPEED, OFUDA_SOUND_1)
		total_wait_time += DURATION * loop
	
	if dog_level >= 7 and miko_dog.has_ability('circular_ofudas'):
		var bullet_num: int = 25 + (25 * (dog_level - 7))
		var loop: int = dog_level - 7
		const DURATION: float = 0.5
		const ROTATION: float = deg_to_rad(135)
		const SPEED: int = 2000
		_pattern_path(%Path3, DURATION, bullet_num, loop, -ROTATION, SPEED, OFUDA_SOUND_3)
		_pattern_path(%Path4, DURATION, bullet_num, loop, ROTATION, SPEED, OFUDA_SOUND_3)
		total_wait_time += DURATION * loop
	
	var wait_timer := get_tree().create_timer(total_wait_time, false)
	await Global.wait(0.5)
	if _cancellation_token.is_canceled(): return

	_pattern_straight_line(direction, MAIN_PATTERN_SPEED, straight_bullets_num, ofuda_red)
	
	_pattern_straight_line(
		direction.rotated(deg_to_rad(7.5)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, ofuda_gray
	)
	_pattern_straight_line(
		direction.rotated(deg_to_rad(-7.5)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, ofuda_gray
	)
	
	if dog_level >= 3:
		_pattern_straight_line(
			direction.rotated(deg_to_rad(15)), MAIN_PATTERN_SPEED, straight_bullets_num / 3, ofuda_red
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-15)), MAIN_PATTERN_SPEED, straight_bullets_num / 3, ofuda_red
		)
	
	if dog_level >= 4:
		const ROTATION: int = 45
		const SPEED: int = 2500
		_pattern_straight_line(
			direction.rotated(deg_to_rad(20)), SPEED, straight_bullets_num, ofuda_red, -ROTATION
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-20)), SPEED, straight_bullets_num, ofuda_red, ROTATION
		)
	
	if wait_timer.time_left > 0:
		await wait_timer.timeout
		if _cancellation_token.is_canceled(): return
	
	if miko_dog.has_ability('yin_yang_orb') and dog_level >= 9:
		await Global.wait(0.25)
		if _cancellation_token.is_canceled(): return
		_spawn_yin_yang_orb(dog_level, Vector2(320, -800))
	
func _spawn_yin_yang_orb(dog_level: int, velocity: Vector2) -> void:
	var yin_yang_orb: YinYangOrb = YIN_YANG_ORB_SCENE.instantiate()
	yin_yang_orb.setup(miko_dog.get_center_global_position(), dog_level, miko_dog.character_type, velocity)
	battlefield.add_child(yin_yang_orb)
		
func _pattern_straight_line(
	direction: Vector2, speed: float, bullet_num: int,
	ofuda_kit: DanmakuBulletKit, rotation: float = 0, back_accel: float = 0
) -> void:
	AudioPlayer.play_in_battle_sfx(OFUDA_SOUND_2)
	var center_pos := miko_dog.get_center_global_position()
	var speed_reduction_unit: float = speed / (bullet_num * 1.5) 
	for i in range(bullet_num):
		var ofuda = danmaku_space.spawn(ofuda_kit, miko_dog)
		ofuda.start(func():
			ofuda.damage = miko_dog.ofuda_damage
			var ofuda_speed = speed - (i * speed_reduction_unit)
			var velocity: Vector2 = direction * ofuda_speed 
			ofuda.velocity = velocity
			ofuda.position = center_pos
			ofuda.velocity_rotation_speed = deg_to_rad(rotation)
			ofuda.acceleration = velocity.normalized() * -back_accel
			await Global.wait(2.0)
			if ofuda.is_destroyed(): return
			ofuda.velocity_rotation_speed = 0
		)

var _pattern_paths: Dictionary = {}
func _pattern_path(
	path: Path2D, duration: float, bullet_num: int, loop: int, rotation: float, speed: float, sfx: AudioStream
) -> void:
	var path_follow := path.get_node("PathFollow2D") as PathFollow2D
	path_follow.progress = 0.0
	var interval: float = 0 if bullet_num == 1 else duration / (bullet_num - 1)
	_pattern_paths[path] = {
		'path_follow': path_follow,
		'interval': interval,
		'sum_delta': interval,
		'sum_delta_sfx': 0,
		'progress_ration_unit': 1.0 / bullet_num,
		'loop': loop,
		'rotation': rotation,
		'speed': speed,
		'ofuda': ofuda_red,
		'sfx': sfx,
		'finished': false
	}

func physics_update(delta) -> void:
	$Patterns.global_position = miko_dog.get_center_global_position()
	
	if _pattern_paths.is_empty():
		return
	
	for path in _pattern_paths:
		var _pattern_data := _pattern_paths[path] as Dictionary
		
		_pattern_data['sum_delta'] += delta
		_pattern_data['sum_delta_sfx'] += delta
		while _pattern_data['sum_delta'] >= _pattern_data['interval']:
			_pattern_data['sum_delta'] -= _pattern_data['interval']
			_spawn_bullet_on_path(_pattern_data)
			
			if _pattern_data['finished']:
				_pattern_paths.erase(path)
				break
			
			const SFX_INTERVAL = 0.09
			if _pattern_data['sum_delta_sfx'] >= SFX_INTERVAL:
				_pattern_data['sum_delta_sfx'] = 0
				AudioPlayer.play_in_battle_sfx(_pattern_data['sfx'])
	
func _spawn_bullet_on_path(_pattern_data: Dictionary) -> void:
	var path_follow := _pattern_data['path_follow'] as PathFollow2D
	var center_global_pos := miko_dog.get_center_global_position()
	var velocity = Vector2(1, 0) * _pattern_data['speed']
	var progress_unit: float = _pattern_data['progress_ration_unit'] 
	var current_loop = _pattern_data['loop']
	
	velocity = velocity.rotated((path_follow.global_position - center_global_pos).angle())
	
	var ofuda := danmaku_space.spawn(_pattern_data['ofuda'], miko_dog)
	ofuda.start( func():
		ofuda.damage = miko_dog.ofuda_damage
		ofuda.position = center_global_pos
		ofuda.velocity = velocity
		ofuda.velocity_rotation_speed = _pattern_data['rotation'] * sign(progress_unit)
		var passed_delta: float = _pattern_data['sum_delta']
		ofuda.process(passed_delta)
		await Global.wait(2.0, passed_delta)
		if ofuda.is_destroyed(): return
		
		ofuda.velocity_rotation_speed = 0
		if current_loop % 2: 
			ofuda.acceleration = -velocity
		
	)
	
	_pattern_data['ofuda'] = (
		ofuda_red if _pattern_data['ofuda'] == ofuda_gray else ofuda_gray
	)
	
	var dest_progress: float = 1.0 if progress_unit > 0 else 0.0
	if is_equal_approx(path_follow.progress_ratio, dest_progress):
		_pattern_data['progress_ration_unit'] = -progress_unit
		_pattern_data['loop'] -= 1
		if _pattern_data['loop'] == 0:
			_pattern_data['finished'] = true
	
	path_follow.progress_ratio += _pattern_data['progress_ration_unit'] 
		
func exit():
	_cancellation_token.cancel()
	_pattern_paths.clear()	
	_twwen.kill()
	miko_dog.rotation = 0
	
	## restart timer if attack interuppted
	if _attacked and miko_dog.n_AttackCooldownTimer.is_stopped():
		miko_dog.n_AttackCooldownTimer.start()
