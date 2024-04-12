@tool
class_name HighlightTextEffect extends RichTextEffect

var bbcode := "hi"

const COLORS = {
	'blue': 0x028ffaff,
	'red': 0xe00400ff,
	'yellow': 0xadba02ff,
}

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var color_code = char_fx.env.get('c', 'blue')
	if not COLORS.has(color_code):
		return false
			
	var color: Color = COLORS[color_code]
	char_fx.color = color.lightened(0.13 + sin(char_fx.elapsed_time * 4.0 + char_fx.relative_index * 0.15) * 0.13) 
	return true
