extends CatTower


const FALL_ACCELERATION := Vector2(-35, 1000)
var velocity := Vector2(-15, 0) 
var tween: Tween
var dest_x_position: float
var falling: bool = false

func setup(tori: Tori) -> void:
	dest_x_position = tori.position.x + 1500; 
	tori.zero_health.connect(_on_zero_health, CONNECT_ONE_SHOT)
	
func _ready() -> void:
	super._ready()

	tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%Sprite2D, "position:y", 20.0, 3.0).as_relative()
	tween.tween_property(%Sprite2D, "position:y", -20.0, 3.0).as_relative()

func _on_zero_health() -> void:
	falling = true
	$AnimationPlayer.play("stop_floating")
	tween.kill()
	
func _process(delta: float) -> void:
	position += velocity * delta
	position.x = max(dest_x_position, position.x)
	
	if falling:
		velocity += FALL_ACCELERATION * delta	
	
	if position.y >= 0:
		position.y = 0
		set_process(false)
		knockback_dogs(1.0)
