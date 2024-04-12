class_name ChatBox extends PanelContainer

const COLOR_LOBBY_EVENT := '#81d3eb'
const COLOR_P2P_EVENT := '#74dba1'
const COLOR_PLAYER := '#ffffff'

func _ready() -> void:
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_message.connect(_on_lobby_message)
	
	var message := "%s (ID: %s)" % [tr("@ROOM_JOINED"), SteamUser.lobby_id]
	
	if SteamUser.STEAM_ID == Steam.getLobbyOwner(SteamUser.lobby_id):
		message = "%s (ID: %s)" % [tr("@ROOM_CREATED"), SteamUser.lobby_id]
		
	display_message(message, COLOR_LOBBY_EVENT, false)

	%SendButton.pressed.connect(_send_message)
	%InputLine.text_submitted.connect(func(_new_text): _send_message())

func _send_message() -> void:
	var message: String = %InputLine.text.strip_edges()
	
	if message.length() > 0:
		print("SENDING MESSAGE")
		var sent := Steam.sendLobbyChatMsg(SteamUser.lobby_id, message)	
		
		if sent:
			%InputLine.clear()

func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	var username: String = Steam.getFriendPersonaName(change_id)
	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		display_message("%s %s" % [username, tr("@PLAYER_HAS_JOINED")], COLOR_LOBBY_EVENT)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		display_message("%s %s" % [username, tr("@PLAYER_HAS_LEFT")], COLOR_LOBBY_EVENT)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		display_message("%s %s" % [username, tr("@PLAYER_HAS_BEEN_KICKED")], COLOR_LOBBY_EVENT)

func _on_lobby_message(_lobby_id: int, user: int, message: String, _chat_type: int):
	var username := Steam.getFriendPersonaName(user)
	display_message("%s: %s" % [username, message], COLOR_PLAYER)
	
func display_message(message: String, color: String, new_line: bool = true):
	if new_line:
		%ChatLog.append_text('\n')
	
	if color == COLOR_PLAYER:
		%ChatLog.append_text("[color=%s]%s[/color]" % [color, message]) 
	else:
		%ChatLog.append_text("[font_size=16][i][color=%s]%s[/color][/i][/font_size]" % [color, message]) 
		
	
