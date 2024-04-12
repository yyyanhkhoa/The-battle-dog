extends TextureButton

func _ready() -> void:
	play_ready_animation()

func play_ready_animation():
	$AnimatedSprite2D.play("ready")

func play_wait_animation():
	$AnimatedSprite2D.play("wait")
