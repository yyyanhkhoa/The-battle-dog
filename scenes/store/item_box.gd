class_name ItemStoreBox extends Control

var _item_data: Dictionary
func get_item_data() -> Dictionary:
	return _item_data

var _item_id: String
func get_item_id() -> String:
	return _item_id

var _parent: Node	
var stylebox_override: StyleBoxFlat

func _ready():
	$AnimationPlayer.play("ready")
	stylebox_override = $Button.get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0xbde300FF)

func setup( data: Dictionary, parent: Node) -> void:
	_item_data = data
	_parent = parent
	_item_id = data['ID']
	
	$Icon.texture = load("res://resources/icons/store/%s_icon.png" % data["ID"])
#	print($Icon.scale())
	update_labels()
	$Button.pressed.connect(_on_pressed)
	
func update_labels():
	var amount = get_amount()
	$Background.frame = 0 if amount > 0 else 1	
	$Amount.visible = true if amount > 0 else false
	$Amount.text = "x %s" % amount
	if amount < 10:
		%Price.text = str(get_price()) 
	else:
		%Price.text = "MAX"
		%BoneIcon.hide()
		$Background.modulate = Color(100, 100, 100)
	
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
	return int(_item_data['price'] + (_item_data['price'] ))

func get_amount() -> int:
	return _get_amount_or_zero(Data.store.get(_item_id))

func _get_amount_or_zero(dict: Variant) -> int:
	return 0 if dict == null else dict.get('amount', 0)

func get_item_name() -> String:
	print(tr("@STORE_NAME_%s" % _item_id))
	return tr("@STORE_NAME_%s" % _item_id)
	

func get_item_description() -> String:
	return tr("@STORE_DESCRIPTION_%s" % _item_id)
