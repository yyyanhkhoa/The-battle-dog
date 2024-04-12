@tool
class_name TypographyTextEffect extends RichTextEffect

var bbcode := "typo"

const pauses = {
	'.': 0.4,
	',': 0.25,
	'-': 0.25,
	'!': 0.25,
	'?': 0.25
}

var pause_time: float = 0.0
var prev_char: String = ""
var finished: bool = false
var max_index: int = 0

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if is_equal_approx(char_fx.elapsed_time, 0.0):
		finished = false
		max_index = 0	
	elif finished == true:
		return true
	
	if char_fx.relative_index == 0:
		pause_time = 0.0
		prev_char = ""
	
	max_index = max(max_index, char_fx.relative_index)
	
	if char_fx.visible: 
		var char: String = String.chr(TextServerManager.get_primary_interface().font_get_char_from_glyph_index(char_fx.font, 1, char_fx.glyph_index))
		if prev_char != char and char != ')':
			pause_time += pauses.get(prev_char, 0.0)
		
		prev_char = char
		
	var char_duration: float = 0.175 / char_fx.env.get('rate', 10.0)
	char_fx.visible = char_fx.elapsed_time > (char_fx.relative_index + 1) * char_duration + pause_time
	
	if char_fx.visible and char_fx.relative_index == max_index:
		finished = true
	
	return true
