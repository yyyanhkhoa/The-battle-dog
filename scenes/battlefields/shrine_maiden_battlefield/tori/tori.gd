class_name Tori extends StaticBody2D

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const SkyInvert: PackedScene = preload("res://scenes/effects/sky_invert/sky_invert.tscn")
const SKY_INVERT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/sky_invert.mp3")

signal zero_health

var danmaku_space: DanmakuSpace
var health: int
var max_health: int
var growl_num: int
var next_growl_health: int

var _bullet_colors := [BulletKits.BulletColor.RED, BulletKits.BulletColor.PINK, BulletKits.BulletColor.YELLOW]

func get_effect_global_position() -> Vector2:
	return $Marker2D.global_position
			
## call this before _enter_tree() is called
func setup(position_x: float, health: int, growl_num: int, instant_spawns: Dictionary) -> void:
	position.x = BaseBattlefield.TOWER_MARGIN + position_x
	self.health = health
	max_health = health
	update_health_label()
	self.growl_num = growl_num
	next_growl_health = max_health - roundi(max_health / (growl_num + 1))
	
	danmaku_space = InBattle.get_danmaku_space()
	var battlefield := InBattle.get_battlefield() as BaseBattlefield 
	for cat_id in instant_spawns:
		var cat_scene: PackedScene = load("res://scenes/characters/cats/%s/%s.tscn" % [cat_id, cat_id])
		for i in range(instant_spawns[cat_id]):
			var cat := cat_scene.instantiate() as BaseCat
			
			if cat is AirUnitCat:
				var rand_offset := Vector2(300, 0).rotated(randf() * PI * 2) 
				cat.change_target_overtime = false 
				cat.setup($FaceMarker.global_position + rand_offset, false)
				cat.target_position = cat.global_position
			else:
				var pos := Vector2($FaceMarker.global_position.x + randf_range(-1000, 1000), 0)
				cat.setup(pos, false)
			
			if Data.character_info[cat_id].has('danmaku_bullets'):
				danmaku_space.register_bullets(Data.character_info[cat_id]['danmaku_bullets'])
			
			battlefield.add_child(cat)	
			
	for bullet_color in _bullet_colors:
		danmaku_space.register_bullet(BulletKits.BULLET_1, bullet_color, 200)
		
func take_damage(damage: int) -> void:
	if health <= 0:
		return
	
	if not InBattle.in_request_mode:
		health = max(health - damage, 0) 
		
	update_health_label()
	
	if health > 0:
		if next_growl_health != 0 and health <= next_growl_health:
			next_growl_health -= roundi(max_health / (growl_num + 1))
			$AnimationPlayer.play("growl")
			$AnimationPlayer.queue("RESET")
			growl()
		else:	
			$AnimationPlayer.play("shake")
			
			
	else:
		$AnimationPlayer.play("destroy")
		zero_health.emit()
		collision_layer = 0
		$HealthLabel.visible = false
		invert_sky()

func invert_sky() -> void:
	AudioPlayer.play_in_battle_sfx_once(SKY_INVERT_AUDIO, 1.0, true)
	
	var sky_invert: FXSkyInvert = SkyInvert.instantiate()
	var battlefield := InBattle.get_battlefield()
	sky_invert.sky_movement_scale = 5
	sky_invert.invert = 0.555
	sky_invert.add = 0x008d00ff
	sky_invert.difference = 0x7d7565ff
	sky_invert.hue_shift = -0.38
	sky_invert.setup(battlefield.get_camera(), battlefield.get_sky(), $FaceMarker.global_position)
	InBattle.get_battlefield().add_child(sky_invert)	

func update_health_label() -> void:
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func growl() -> void:
	var effect: FXEnergyExpand = EnergyExpand.instantiate()
	effect.setup($FaceMarker.global_position, "on_emitter")
	InBattle.get_battlefield().get_effect_space().add_child(effect)
	
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.knockback(1.5)

	for i in range(4):
		var pattern := Danmaku.pattern_cirle($FaceMarker.global_position, 100) as DanmakuPatternCircle
		pattern.step = deg_to_rad(10)
		pattern.angle_offset = deg_to_rad(-45 + i * 90)
		pattern.clockwise_direction = i % 2 == 0
		pattern.start(1, _on_pattern_callback)
		
	for i in range(4):
		var pattern := Danmaku.pattern_cirle($FaceMarker.global_position, 400) as DanmakuPatternCircle
		pattern.step = deg_to_rad(10)
		pattern.angle_offset = deg_to_rad(-90 + i * 90)
		pattern.clockwise_direction = i % 2 == 0
		pattern.start(1, _on_pattern_callback)
	
func _on_pattern_callback(position: Vector2, angle: float, passed_delta: float, index: int) -> void:
	var bullet_kit = Danmaku.get_bullet_kit(BulletKits.BULLET_1, _bullet_colors.pick_random())
	var bullet := danmaku_space.spawn_no_owner(bullet_kit, Character.Type.CAT)
	bullet.start(func():
		bullet.damage *= (InBattle.get_battlefield() as Battlefield).get_cat_power_scale()
		bullet.position = position
		bullet.rotation = angle
		bullet.velocity = Vector2(900 - 20 * index, 0).rotated(angle)
		bullet.velocity_rotation_speed = deg_to_rad(100 * (2 * int(index % 2) - 1))
		bullet.process(passed_delta);
		
		var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(bullet, "velocity_scale", 0.0, 2.0)
		await tween.finished
		
		if bullet.is_destroyed(): return
		
		bullet.velocity_rotation_speed = 0
		var new_velocity: Vector2
		var dogs := get_tree().get_nodes_in_group("dogs")
		if dogs.is_empty():
			new_velocity = Vector2(bullet.velocity.length(), 0).rotated(deg_to_rad(90 + 45))
		else:
			var dog := dogs.pick_random() as BaseDog
			new_velocity = Vector2(bullet.velocity.length(), 0).rotated((dog.global_position - bullet.position).angle())
				
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(bullet, "rotation", new_velocity.angle(), 1.0).from(bullet.velocity.angle() + deg_to_rad(5.0))
		
		tween.tween_property(bullet, "velocity_scale", 1.0, 2.0)
		tween.parallel().tween_property(bullet, "velocity_rotation_speed", deg_to_rad(-5.0), 2.0)

		bullet.velocity = new_velocity * randf_range(5.0, 10.0)
	)
