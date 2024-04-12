extends IconButton


func _ready() -> void:
	super._ready()
	mouse_entered.connect(func(): $AnimationPlayer.play("on"))
	mouse_exited.connect(func(): $AnimationPlayer.play("off"))
	pressed.connect(_go_to_chapter_selection)

func _go_to_chapter_selection() -> void:
	get_tree().change_scene_to_file("res://scenes/chapter_selection/chapter_selection.tscn")
