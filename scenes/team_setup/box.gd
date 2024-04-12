extends Button

var _item_data: Dictionary
func get_item_data() -> Dictionary:
	return _item_data

var _item_id: String
func get_item_id() -> String:
	return _item_id

var _type: String
func get_item_type() -> String:
	return _type
	
var _parent: Node	
var stylebox_override: StyleBoxFlat

func _ready():
	$AnimationPlayer.play("ready")
	stylebox_override = self.get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0xbde300FF)

func setup(data, parent: Node) -> void:
	_parent = parent
	if (data != null) :
		_item_data = data
		_item_id = data['ID']
		$Icon.texture = load("res://resources/icons/%s_icon.png" % data["ID"])
	
	self.pressed.connect(_on_pressed)


func _on_pressed():
	_parent.deleteInfo($ID.text,$Icon.texture, text)
	#_parent.deleteInfo($ID.text,$TextureRect.texture, text)

func set_selected(selected: bool):
	if selected:
		self.add_theme_stylebox_override("normal", stylebox_override)
		self.add_theme_stylebox_override("hover", stylebox_override)
	else:
		self.remove_theme_stylebox_override("normal")
		self.remove_theme_stylebox_override("hover")
