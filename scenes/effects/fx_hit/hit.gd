class_name FXHit extends Node2D

func setup(global_position: Vector2) -> void:
	self.global_position = global_position
	rotation_degrees = randi_range(0, 360)
	$AnimatedSprite2D.play("default")
	await $AnimatedSprite2D.animation_finished
	get_parent().remove_child(self)

