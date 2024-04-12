class_name PlayerSlot extends PanelContainer

var _id: int

func setup_empty():
	%NotEmpty.hide()
	%Empty.show()
		
func setup(id: int):
	_id = id
	update_ui()

func update_ui():
	%NotEmpty.show()
	%Empty.hide()
	
	var username := Steam.getFriendPersonaName(_id) 
	%PlayerNameLabel.text = "@LOADING" if username == "" else username
	
	if _id == Steam.getLobbyOwner(SteamUser.lobby_id):
		%ReadyLabel.text = "@OWNER"
	else:
		var ready = Steam.getLobbyMemberData(SteamUser.lobby_id, _id, "ready")
		%ReadyLabel.text = "@READY" if ready == "true" else "@NOT_READY" 
