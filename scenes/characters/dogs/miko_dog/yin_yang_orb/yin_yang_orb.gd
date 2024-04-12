class_name YinYangOrb extends CharacterBody2D

const EXIT_AUDIO: AudioStream = preload("res://scenes/characters/dogs/miko_dog/yin_yang_orb/se_don00.wav")
const HIT_SFX: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_damage00.wav") 
const BOUNCE_SFX: AudioStream = preload("res://scenes/characters/dogs/miko_dog/yin_yang_orb/se_chargeup.wav") 

const BOUNCE_SPEED: float = 1000
var _bounce_time_left: int = 1

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var _damage = 50

func setup(global_position: Vector2, dog_level: int, character_type: Character.Type, velocity: Vector2) -> void:
	self.global_position = global_position
	self.velocity = velocity
	
	if character_type == Character.Type.CAT:
		self.velocity.x = -abs(velocity.x)
		collision_mask = 0b100001
		$Area2D.collision_mask = 0b10
	
	_damage = _damage + (dog_level * 10)
	
	_bounce_time_left = _bounce_time_left
	if dog_level >= 3:
		_bounce_time_left += 1
		
	if dog_level >= 6:
		_bounce_time_left += 1
	
	$Area2D.body_entered.connect(_on_enenmy_entered)
	
func _ready() -> void:
	AudioPlayer.play_in_battle_sfx(BOUNCE_SFX)
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property($AnimatedSprite2D, "rotation", deg_to_rad(360), 4).from_current()
	
	var rand_y: int = randi_range(-20, 20)
	$AnimatedSprite2D.position += Vector2(randi_range(-20, 20), rand_y)
	z_index = rand_y + 20
	
func _on_enenmy_entered(enemy: Character) -> void:
	if not InBattle.in_request_mode:
		enemy.take_damage(_damage)
	
	var distance: float = enemy.global_position.distance_to(global_position) / 2
	var fx_position: Vector2 = enemy.global_position.move_toward(global_position, distance)
	
	InBattle.add_hit_effect(fx_position)
		
func _physics_process(delta: float) -> void:
	velocity.y += _gravity * delta
	var collision = move_and_collide(velocity * delta)
	var _prev_velocity := velocity
	
	if not collision:
		return
		
	var collider := collision.get_collider()

	if collider is Land:
		if _bounce_time_left == 0:
			_destroy()
			return
		
		AudioPlayer.play_in_battle_sfx(BOUNCE_SFX)
		_bounce_time_left -= 1
		
		var remainder_delta: float = collision.get_remainder().x / _prev_velocity.x
		velocity.y = -BOUNCE_SPEED
		velocity.y += _gravity * remainder_delta	
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2(1.25, 1), 0.1)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1)	
	else:
		AudioPlayer.play_in_battle_sfx(HIT_SFX)
		
		# is tower
		collider.take_damage(_damage)
		InBattle.add_hit_effect(collision.get_position())
	
		_destroy()

func _destroy():
	AudioPlayer.play_in_battle_sfx(EXIT_AUDIO)
	set_physics_process(false)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.1)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation", deg_to_rad(360 * 4), 0.3)
	
	await tween.finished
	$Area2D/CollisionShape2D.disabled = true
	
	queue_free()	
