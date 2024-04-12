extends CanvasGroup

func _process(delta: float) -> void:
	if material != null:
		(material as ShaderMaterial).set_shader_parameter("zoom", get_viewport_transform().get_scale().y)
 

