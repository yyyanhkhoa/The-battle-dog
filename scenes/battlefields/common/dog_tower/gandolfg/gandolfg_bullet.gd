class_name GandolfgBullet extends Area2D

const SPELL_CAST_AUDIO: AudioStream = preload("res://scenes/battlefields/common/dog_tower/gandolfg/electric_ball.mp3")
const HIT_AUDIO: AudioStream = preload("res://scenes/battlefields/common/dog_tower/gandolfg/electric_ball_hit.mp3")

const BASE_DAMAGE = 50
const SPEED = 700
var _stop_following: bool = false
var _direction: Vector2 = Vector2(0.5, 0.5) 
var _target: Character

var _collided: bool = false

func _ready():
	set_physics_process(false)
	rotation = randi_range(0, 360)
	var tween := create_tween()
	tween.set_loops(0)
	tween.tween_property(self, "rotation", 360, 120.0).as_relative()
	tween.bind_node(self)
		
func setup(global_position: Vector2, target: Character) :
	_target = target  
	self.global_position = global_position 
	
	AudioPlayer.play_in_battle_sfx(SPELL_CAST_AUDIO, AudioPlayer.get_random_pitch_scale())
	_calculate_direction()
	
	# Khong thay doi vi tri vien dan nua neu meo da chet hoac dang bi vap nga
	target.tree_exiting.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)
	target.knockbacked.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.45).from(Vector2(0, 0))
	await tween.finished
	
	body_entered.connect(_on_body_entered)
	set_physics_process(true)

func _calculate_direction():
	_direction = (_target.global_position - global_position).normalized()
	
func _physics_process(delta):
	if not _stop_following:
		_calculate_direction()
	
	position += _direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:	
	InBattle.add_hit_effect(global_position)
	
	if body is Character:
		var level := InBattle.get_passive_level("gandolfg")
		body.take_damage(BASE_DAMAGE + (level * 10))
	
	if _collided:
		return
	
	_collided = true
	AudioPlayer.play_in_battle_sfx(HIT_AUDIO, AudioPlayer.get_random_pitch_scale())
	
	set_physics_process(false)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.25)
	
	await tween.finished
	$CollisionShape2D.disabled = true
	
	queue_free()
