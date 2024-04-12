extends Sprite2D

func _ready() -> void:
	item_rect_changed.connect(_on_item_rect_changed)
	
	var battlefield := InBattle.get_battlefield() as Battlefield
	scale.x = float(battlefield.get_stage_width()) / get_rect().size.x
	_on_item_rect_changed() 

func _process(delta: float) -> void:
	(material as ShaderMaterial).set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)

func _on_item_rect_changed() -> void:
	(material as ShaderMaterial).set_shader_parameter("scale", scale)
