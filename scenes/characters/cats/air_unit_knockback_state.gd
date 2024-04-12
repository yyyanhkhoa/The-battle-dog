class_name AirUnitKnockbackState extends FSMState

@export var destroy_bullets: bool = true

@onready var cat: AirUnitCat = owner
var knockback_countdown: int
var knockback_vel: Vector2

func enter(data: Dictionary) -> void:
	cat.floating_movement_tween.pause()
	
	knockback_vel = Vector2(200, -450) * data['scale']
	if cat.health <= 0:
		knockback_vel = Vector2(400, -800)
	
	cat.n_AnimationPlayer.play("knockback")
		
	cat.velocity.x = knockback_vel.x * -cat.move_direction
	cat.velocity.y = knockback_vel.y
	knockback_countdown = 1
	
	if destroy_bullets:
		InBattle.get_danmaku_space().destroy_bullets_of(cat)

# called when the state is deactivated
func exit() -> void:
	cat.n_DanmakuHitbox.set_deferred("monitoring", true)
	if cat.character_type == cat.Type.DOG:
		cat.set_collision_layer_value(2, true)
	else: 
		cat.set_collision_layer_value(3, true) 
		
# called every frame when the state is active
func physics_update(delta: float) -> void:
	if not cat.is_on_floor():
		cat.velocity.y += cat.gravity * delta
		
		if cat.health <= 0 and cat.velocity.y >= 300:
			transition.emit("DieState")
			return
		
		cat.move_and_slide() 
		return
	
	var _prev_velocity = cat.velocity
	if knockback_countdown > 0:
		cat.velocity.x = knockback_vel.x * -cat.move_direction
		cat.velocity.y = knockback_vel.y
		
		var collision := cat.get_slide_collision(0)
		var remainder_delta: float = collision.get_remainder().x / _prev_velocity.x
		cat.velocity.y += cat.gravity * remainder_delta
		
		knockback_countdown -= 1
		knockback_vel = knockback_vel * 0.75
		cat.move_and_slide() 
	else:
		transition.emit("IdleState", { "wait_time": 2.0, "knockedback": true })
