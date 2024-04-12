class_name ItemUpgradeBox extends Control

enum Type { CHARACTER, SKILL, PASSIVE }

var _item_data: Dictionary
func get_item_data() -> Dictionary:
	return _item_data

var _item_id: String
func get_item_id() -> String:
	return _item_id

var _type: Type
func get_item_type() -> Type:
	return _type
	
var _parent: Node	
var stylebox_override: StyleBoxFlat

func _ready():
	$AnimationPlayer.play("ready")
	stylebox_override = $Button.get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0xbde300FF)

func setup(type: Type, data: Dictionary, parent: Node) -> void:
	_item_data = data
	_parent = parent
	_type = type
	_item_id = data['ID']
	if type == Type.SKILL:
		$Icon.texture = load("res://resources/images/skills/%s_icon.png" % data["ID"])
	elif type == Type.CHARACTER:
		$Icon.texture = load("res://resources/icons/%s_icon.png" % data["ID"])
	else:
		$Icon.texture = load("res://resources/icons/passives/%s_icon.png" % data["ID"])
		
	update_labels()
	$Button.pressed.connect(_on_pressed)
	
func update_labels():
	var level = get_level()
	$Background.frame = 0 if level > 0 else 1	
	$Level.visible = true if level > 0 else false
	$Level.text = "Level. %s" % level
	if level < 10:
		%Price.text = str(get_price()) 
	else:
		%Price.text = "MAX"
		%BoneIcon.hide()
		$Background.modulate = Color(1.25, 1.25, 1.25)
	
func _on_pressed():
	_parent.sendInfo(self)

func set_selected(selected: bool):
	if selected:
		$Button.add_theme_stylebox_override("normal", stylebox_override)
		$Button.add_theme_stylebox_override("hover", stylebox_override)
	else:
		$Button.remove_theme_stylebox_override("normal")
		$Button.remove_theme_stylebox_override("hover")

func get_price() -> int:
	return int(_item_data['price'] + (_item_data['price'] * pow(get_level(), 1.5)))

func get_level() -> int:
	if _type == Type.SKILL:
		return _get_level_or_zero(Data.skills.get(_item_id))
	elif _type == Type.CHARACTER:
		return _get_level_or_zero(Data.dogs.get(_item_id))
	else:
		return _get_level_or_zero(Data.passives.get(_item_id))

func _get_level_or_zero(dict: Variant) -> int:
	return 0 if dict == null else dict.get('level', 0)

func get_item_name() -> String:
	if _type == Type.CHARACTER:
		return tr("@DOG_NAME_%s" % _item_id)
	elif _type == Type.SKILL:
		return tr("@SKILL_NAME_%s" % _item_id)
	else:
		return tr("@PASSIVE_NAME_%s" % _item_id)

func get_item_description() -> String:
	if _type == Type.CHARACTER:
		return tr("@DOG_DESCRIPTION_%s" % _item_id)
	elif _type == Type.SKILL:
		return tr("@SKILL_DESCRIPTION_%s" % _item_id)
	else:
		return tr("@PASSIVE_DESCRIPTION_%s" % _item_id)
