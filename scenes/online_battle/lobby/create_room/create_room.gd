extends PanelContainer

signal create_room_request(name: String)

func _ready() -> void:
	%RoomNameLabel.text = tr("@ROOM_NAME") + ":"
	%RoomNameInput.text_changed.connect(_on_text_changed)
	%CreateButton.pressed.connect(func(): create_room_request.emit(%RoomNameInput.text))
	%RoomNameInput.text_submitted.connect(func(text: String):
		if not %CreateButton.disabled:
			create_room_request.emit(text)
	)

func _on_text_changed(new_text: String):
	%CreateButton.disabled = new_text.length() == 0

func set_create_button_disabled(disabled: bool):
	%CreateButton.disabled = disabled
