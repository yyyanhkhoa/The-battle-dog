class_name Stage extends Button

var _stage_id: String 
var _stage_name: String
func get_stage_name(): return _stage_name  

var _stage_index: int
func get_stage_index(): return _stage_index

## Acts as a doubly linked-list
var next_stage: Stage
var prev_stage: Stage

var stylebox_override: StyleBoxFlat
	
func _ready() -> void:
	stylebox_override = get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0x960000FF)
	stylebox_override.bg_color = Color.hex(0xEE0000FF)
	
func setup(stage_id: String, stage_index: int, prev_stage_node: Stage, next_stage_node: Stage) -> void:
	_stage_id = stage_id
	_stage_index = stage_index
	_stage_name = tr("@STAGE_%s" % stage_id)
	$Flag.visible = _stage_index <= Data.passed_stage
	
	if _stage_index > Data.passed_stage + 1:
		disabled = true
		return
	
	prev_stage = prev_stage_node
	next_stage = next_stage_node
	pressed.connect(func(): set_selected(true))
	
func set_selected(selected: bool):
	if selected:
		add_theme_stylebox_override("normal", stylebox_override)
		Data.selected_stage_id = _stage_id
		Data.selected_stage = _stage_index
	else:
		remove_theme_stylebox_override("normal")
	
