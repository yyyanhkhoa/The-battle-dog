extends Node

const NIGHT_SKY = preload("res://resources/battlefield_themes/night/sky.png")
const HEAVENLY_LAND = preload("res://resources/battlefield_themes/heavenly/land.png")

func _ready() -> void:
	# SOME STRANG BS, HAVE TO PRELOAD TO FIX
	$Sky.texture = NIGHT_SKY
	$Land.texture = HEAVENLY_LAND
	
	$SkipButton.pressed.connect(_on_skip, CONNECT_ONE_SHOT)
	$AnimationPlayerText.animation_finished.connect(func(anim_name): 
		$SkipButton.pressed.disconnect(_on_skip)
		await get_tree().create_timer(5).timeout
		_on_finished()
	)

func _on_skip() -> void:
	$AnimationPlayer.pause()
	_on_finished()
	
func _on_finished() -> void:
	$ColorRect.visible = true
	
	if Data.dogs.has("batter_dog"):
		$AnimatedSprite2D.play("bad_ending")
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($ColorRect, "color:a8", 255, 1.5)
	tween.tween_property($Music, "volume_db", -40, 1.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")

