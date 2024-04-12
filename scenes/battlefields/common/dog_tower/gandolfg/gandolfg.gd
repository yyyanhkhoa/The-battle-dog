class_name Gandolfg extends Node2D

const ATTACK_FRAME: int = 8
const BASE_ATTACK_RANGE: int = 1500
const BASE_ATTACK_COOLDOWN: int = 13

const BULLET_SCENE: PackedScene = preload("res://scenes/battlefields/common/dog_tower/gandolfg/gandolfg_bullet.tscn")
var _ennemies: Array[Character] = [] 

var _closest_enemy: Character
func get_cloeset_enemy() -> Character: return _closest_enemy

func setup(global_position: Vector2):
	self.global_position = global_position
	var level := InBattle.get_passive_level('gandolfg')
	$AttackCooldownTimer.wait_time = BASE_ATTACK_COOLDOWN - (level * 1)
	$AttackArea/AttackCollisionShape.shape.radius = BASE_ATTACK_RANGE + (150 * level)
	$AttackArea.body_entered.connect(_on_attack_area_body_entered)
	$AttackArea.body_exited.connect(_on_attack_area_body_exit)
	$AttackCooldownTimer.timeout.connect(_on_cooldown_time_out)
	%Staff.frame_changed.connect(_on_attack_frame_changed)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	
func _process(delta):
	_closest_enemy = Global.find_closest(self, _ennemies)

	if _closest_enemy != null: 
		%StaffWrapper.look_at(_closest_enemy.position)
	else:
		%StaffWrapper.rotation = 0
	
func _on_attack_area_body_entered(body: Character):
	_ennemies.append(body)
	
	if $AttackCooldownTimer.is_stopped():
		$AnimationPlayer.play("attack")
		
func _on_attack_area_body_exit(body: Character):
	_ennemies.erase(body)

func _on_attack_frame_changed() -> void:
	if %GandolfgSprite.frame == ATTACK_FRAME:
		if _closest_enemy != null:
			var bullet: GandolfgBullet = BULLET_SCENE.instantiate()
			get_tree().current_scene.add_child(bullet)
			bullet.setup(%BulletSpawnMarker.global_position, _closest_enemy)
		else:
			var closest_enemy = Global.find_closest(self, get_tree().get_nodes_in_group("enemies"))
			if closest_enemy != null:
				var bullet: GandolfgBullet = BULLET_SCENE.instantiate()
				get_tree().current_scene.add_child(bullet)
				bullet.setup(%BulletSpawnMarker.global_position, closest_enemy)
		
		$AttackCooldownTimer.start()

func _on_cooldown_time_out() -> void:
	if _closest_enemy != null and $AttackCooldownTimer.is_stopped():
		$AnimationPlayer.play("attack")
	else:
		$AnimationPlayer.play("idle")
		
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		$AnimationPlayer.play("idle")
	var closest_enemy: Character = null
	var min_distance: float = 1.79769e308
	
