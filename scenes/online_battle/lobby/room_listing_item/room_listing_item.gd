class_name RoomListingItem extends PanelContainer

signal join_request(room_id: int)

func setup(room_id: int, room_name: String, member_count: int):
	%Name.text = room_name
	%Capacity.text = "%s/2" % member_count
	%JoinButton.pressed.connect(func(): join_request.emit(room_id))
	%JoinButton.disabled = member_count > 1
		

func set_join_button_disabled(disabled: bool):
	%JoinButton.disabled = disabled
