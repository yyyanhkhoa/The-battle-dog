extends Control

const KeyBindingBoxScene: PackedScene = preload("res://scenes/settings/key_binding_settings/key_binding_box/key_binding_box.tscn")
const KeyBindingListenerScene: PackedScene = preload("res://scenes/settings/key_binding_settings/key_binding_listener/key_binding_listener.tscn")

const _action_list = [
	"ui_fullscreen",
	"ui_confirm",
	"ui_cancel",
	"ui_zoomin",
	"ui_zoomout",
	"ui_switch_row",
	"ui_spawn_1",
	"ui_spawn_2",
	"ui_spawn_3",
	"ui_spawn_4",
	"ui_spawn_5",
	"ui_skill_1",
	"ui_skill_2",
	"ui_skill_3",
	"ui_upgrade_efficiency",
	"ui_switch_time_scale",
	"ui_pause"
]

var key_binding_boxes: Array[KeyBindingBox] = []

func _ready() -> void:
	for action in _action_list:
		var key_binding_box: KeyBindingBox = KeyBindingBoxScene.instantiate()
		key_binding_box.setup(action)
		key_binding_box.key_binding_requested.connect(_on_key_binding_requested)
		%KeyBindingContainer.add_child(key_binding_box)
		key_binding_boxes.push_back(key_binding_box)
	
	%ResetToDefaultButton.pressed.connect(_on_reset_to_default_pressed)
	%ResetKeyBindingPopup.confirm.connect(_reset_keybinding_settings)
		
func _on_key_binding_requested(action: String):
	var listener = KeyBindingListenerScene.instantiate()
	listener.setup(action)
	get_parent().add_child(listener)
	
	listener.ok.connect(_bind_key)

func _bind_key(action: String, input: InputEvent):
	### TODO: support other input types other than keyboard (like joystick or smt) 
	if not (input is InputEventKey):
		return

	var key := input as InputEventKey 
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
	
	Data.save_data['settings']['key_binding_overwrites'][action] = key.keycode
	Data.save()
	
	var key_binding_box = key_binding_boxes.filter(func(x): return x.get_action() == action)[0]
	key_binding_box.update_ui()

func _on_reset_to_default_pressed() -> void:
	%ResetKeyBindingPopup.popup(tr("@CONFIRM_RESET_KEY_BINDING_SETTINGS"), PopupDialog.Type.CONFIRMATION)
			
func _reset_keybinding_settings() -> void:
	InputMap.load_from_project_settings()
	Data.save_data['settings']['key_binding_overwrites'] = {}
	Data.save()
	for box in key_binding_boxes:
		box.update_ui()	
