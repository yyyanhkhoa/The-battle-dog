@tool
class_name JumpTextEffect extends RichTextEffect

var bbcode := "jump"

var wait: float = 0.0
var jump_count: int = 0

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if (is_zero_approx(char_fx.elapsed_time)):
		wait = 0.0
		jump_count = 0
	
	elif wait > char_fx.elapsed_time:
		return true
		
	var offset := sin((char_fx.elapsed_time - wait) * 12.0) * 0.5
	
	if offset < 0.0:
		jump_count += 1;
		wait = char_fx.elapsed_time
		
		if jump_count > 1:
			jump_count = 0
			var wait_duration: float = char_fx.env.get('wait', 1.0)
			wait = char_fx.elapsed_time + wait_duration
			return true
		
	
	char_fx.offset = Vector2(0, -10) * offset
	return true
