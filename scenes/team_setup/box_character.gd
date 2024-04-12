class_name SelectCharacterBox extends Button

enum Type { CHARACTER, SKILL, NONE, STORE }

var _type: Type
func get_item_type() -> Type:
	return _type

# String or null
var _item_id: Variant
func get_item_id() -> Variant:
	return _item_id

func setup(item_id: String, type: Type) -> void:
	_type = type
	_item_id = item_id
	
	if type == Type.CHARACTER:
		$Icon.texture = load("res://resources/icons/%s_icon.png" % item_id)
	elif type == Type.SKILL:
		$Icon.texture = load("res://resources/images/skills/%s_icon.png" % item_id)
	else: 
		$Icon.texture = load("res://resources/icons/store/%s_icon.png" % item_id)
		

func change_item(item_id: String, type: Type) -> void:
	setup(item_id, type)

func clear() -> void:
	$Icon.texture = null
	_type = Type.NONE
	_item_id = null
