extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool

const MESSAGE_READ_LIMIT: int = 32

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""
var PASSWORD: String = ""

# lobby
var lobby_id: int = 0
var lobby_members: Array
var data

## game connection
var listen_socket: int = 0

# In battle variables
## In battle player data (this data will stay even if player left the game / lobby mid game).
## The first player in the list is the left dog tower, second player is the right tower.
var players: Array

## the other player that connecting to the room owner socket 
var connection_handle: int = 0

enum SendType {
	UNRELIABLE = 0, NO_NAGLE = 1, NO_DELAY = 4, RELIABLE = 8, 
}
signal sw_dangky

func is_logged_on() -> bool:
	return Steam.loggedOn()

func _ready() -> void:
	process_mode =  PROCESS_MODE_ALWAYS
	
	var INIT: Dictionary = Steam.steamInit(false)
	print("Did Steam initialize?: "+str(INIT))	
	IS_USING_STEAM = Steam.loggedOn()
	Data.silentwolf_data = Data.save_data
	
	if IS_USING_STEAM: #have account
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
		lobby_members = [STEAM_ID]
		Steam.initRelayNetworkAccess()
		PASSWORD = "Aa1@" + str( STEAM_ID)
		
		SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
		SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
		
		Data.save()
	if not IS_USING_STEAM:
		set_process_input(false)

func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Login succeeded!")
		await dang_nhap_sw()
	else:
		#register by STEAM_USERNAME(username) and STEAM_ID(password)
		var sw_register = await SilentWolf.Auth.register_player_user_password(STEAM_USERNAME, PASSWORD, PASSWORD).sw_registration_user_pwd_complete		
		if sw_register.success :
			await dang_ky_sw()
			sw_dangky.connect(dang_nhap_sw)
	
func dang_ky_sw():
	print("dang_ky_sw")
	Data.silentwolf_data.date = Time.get_datetime_string_from_system()
	Data.silentwolf_data.user_name = STEAM_USERNAME
	await SilentWolf.Players.save_player_data(STEAM_USERNAME, Data.silentwolf_data)
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)

func dang_nhap_sw():
	var sw_result = await SilentWolf.Players.get_player_data(STEAM_USERNAME).sw_get_player_data_complete
	Data.silentwolf_data = sw_result.player_data
	if Data.save_data.user_name == "" :
		Data.save_data.user_name = STEAM_USERNAME
		Data.select_data = true
	if Data.silentwolf_data.user_name == Data.save_data.user_name:
		var date1 = Time.get_unix_time_from_datetime_string(Data.save_data.date)
		var date2 = Time.get_unix_time_from_datetime_string(Data.silentwolf_data.date)
		if date2 > date1: #luu silentwolf_data vao data			
			Data.save_data = Data.silentwolf_data
		else : #luu data vao silentwolf_data
			Data.silentwolf_data = Data.save_data
		Data.use_sw_data = true
	else :
		Data.select_data = true

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Registration succeeded!")
	else:
		print("Error: " + str(sw_result.error))

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func update_lobby_members():
	lobby_members.clear()
	for i in range(0, Steam.getNumLobbyMembers(lobby_id)):
		lobby_members.append(Steam.getLobbyMemberByIndex(lobby_id, i)) 
	print("STEAM_USER: LOBBY MEMBERS: %s " % ",".join(lobby_members))	

func send_message(packet_data, send_type: SteamUser.SendType) -> void:
	var data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	Steam.sendMessageToConnection(connection_handle, data, send_type)
	
func read_messages():
	var arr: Array = Steam.receiveMessagesOnConnection(connection_handle, MESSAGE_READ_LIMIT)
	for dict in arr:
		dict['data'] = bytes_to_var(dict['payload'].decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
	
	return arr

func get_lobby_data(key: String) -> String:
	return Steam.getLobbyData(SteamUser.lobby_id, key)

func set_lobby_data(key: String, value: String) -> void:
	Steam.setLobbyData(SteamUser.lobby_id, key, value)

func set_lobby_member_data(key: String, value: String) -> void:
	Steam.setLobbyMemberData(SteamUser.lobby_id, key, value)

func get_member_data(member_id: int, key: String) -> String:
	return Steam.getLobbyMemberData(lobby_id, member_id, key)
	
func get_lobby_owner() -> int:
	return Steam.getLobbyOwner(lobby_id)

func is_lobby_owner() -> bool:
	return SteamUser.STEAM_ID == get_lobby_owner()

func close_connection(connection_handle: int) -> void:
	print("CLOSE CONNECTION: " + str(connection_handle))
	Steam.closeConnection(connection_handle, Steam.CONNECTION_END_REMOTE_TIMEOUT, "CLOSE CONNECTION", false)
	SteamUser.connection_handle = 0

func create_listen_socket():
	SteamUser.listen_socket = Steam.createListenSocketP2P(0, [])
	print("new listen socket: %s" % SteamUser.listen_socket)
