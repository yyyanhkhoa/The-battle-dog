extends Control

const LOBBY_MAX_MEMBERS = 2
const ROOM_LISTING_ITEM_SCENE: PackedScene = preload("res://scenes/online_battle/lobby/room_listing_item/room_listing_item.tscn")
const MAIN_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/main_theme.mp3")

var _request_create_room_name: String

func _ready():
	if not SteamUser.is_logged_on():
		$Popup.popup("@QUIT_GAME_STEAM_DISCONNECTED", PopupDialog.Type.INFORMATION)
		await $Popup.ok
		get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	
	%JoinWithCodeLabel.text = "%s:" % tr("@JOIN_WITH_CODE")
	
	AudioPlayer.play_music(MAIN_THEME_AUDIO, true, true)
	Steam.lobby_created.connect(_on_lobby_created)
	
	%GoBackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	)

	%RefreshButton.pressed.connect(_refresh_room_listing)
	
	%RoomCodeInput.text_changed.connect(func(_new_text):
		%JoinWithCodeButton.disabled = false if %RoomCodeInput.text.is_valid_int() else true
	)
	%RoomCodeInput.text_submitted.connect(func(text: String):
		if not %JoinWithCodeButton.disabled:
			_on_join_lobby_with_code()
	)
	
	%AutoMatchmakingButton.pressed.connect(_auto_matchmaking)
	%JoinWithCodeButton.pressed.connect(_on_join_lobby_with_code)
	
	
	%CreateRoom.create_room_request.connect(_on_create_Lobby_request)
	_refresh_room_listing()
	
	# Check for command line arguments
	_check_Command_Line()
	
var _request_room_loop: int = 0
func _refresh_room_listing():
	if not Steam.lobby_match_list.is_connected(_on_lobby_match_list):
		Steam.lobby_match_list.connect(_on_lobby_match_list)
		
	%RefreshButton.disabled = true
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	_apply_room_filter()
	Steam.requestLobbyList()
	
func _apply_room_filter():
	Steam.addRequestLobbyListStringFilter("game", "thebattledogs", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.addRequestLobbyListStringFilter("game_status", "waiting", Steam.LOBBY_COMPARISON_EQUAL)

func _on_lobby_match_list(lobbies: Array) -> void:
	%RefreshButton.disabled = false
	%RoomCountLabel.text = "%s %s" % [lobbies.size(), tr("@ROOM")]

	if lobbies.size() == 0 && _request_room_loop < 1:
		_request_room_loop += 1
		_refresh_room_listing()
		return
	else:
		Steam.lobby_match_list.disconnect(_on_lobby_match_list)
	
	_request_room_loop = 0
	
	for room in %Rooms.get_children():
		room.queue_free()	
		
	for lobby_id in lobbies:
		var room_name: String = Steam.getLobbyData(lobby_id, "name")
		var member_count: int = Steam.getNumLobbyMembers(lobby_id)
		
		var room: RoomListingItem = ROOM_LISTING_ITEM_SCENE.instantiate()
		room.setup(lobby_id, room_name, member_count)
		
		room.join_request.connect(_on_room_listing_item_join_request.bind(room))
		
		%Rooms.add_child(room)

func _on_create_Lobby_request(room_name: String) -> void:
	%CreateRoom.set_create_button_disabled(true)
	$Popup.popup("@CREATING_ROOM", PopupDialog.Type.PROGRESS)
	_create_Lobby(room_name)
	await Steam.lobby_created
	%CreateRoom.set_create_button_disabled(false)

func _create_Lobby(room_name: String) -> void:
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, LOBBY_MAX_MEMBERS)
	_request_create_room_name = room_name

func _on_lobby_created(connect: int, lobby_id: int) -> void:
	if connect != 1:
		$Popup.popup("@ROOM_CREATE_FAILED", PopupDialog.Type.INFORMATION)
		return
	
	SteamUser.lobby_members = [SteamUser.STEAM_ID]
	
	print("room created: " + str(lobby_id))
	# Set the lobby ID
	SteamUser.lobby_id = lobby_id
	print("Created a lobby: " + str(lobby_id))

	# Set this lobby as joinable, just in case, though this should be done by default
	Steam.setLobbyJoinable(lobby_id, true)

	# Set some lobby data
	SteamUser.set_lobby_data("name", _request_create_room_name)
	SteamUser.set_lobby_data("game", "thebattledogs")
	SteamUser.set_lobby_data("mode", "GodotSteam test")
	SteamUser.set_lobby_data("game_status", "waiting")
	
	_go_to_room()

func _on_room_listing_item_join_request(room_id: int, room: RoomListingItem):
	room.set_join_button_disabled(true)
	%Popup.popup(tr("@ROOM_JOINING"), PopupDialog.Type.PROGRESS)			
	Steam.lobby_joined.connect(_on_lobby_joined, CONNECT_ONE_SHOT)
	Steam.joinLobby(room_id)
	await Steam.lobby_joined
	room.set_join_button_disabled(false)
	_refresh_room_listing()

func _on_join_lobby_with_code(): 
	%JoinWithCodeButton.disabled = true
	%Popup.popup(tr("@ROOM_JOINING"), PopupDialog.Type.PROGRESS)			
	Steam.lobby_joined.connect(_on_lobby_joined, CONNECT_ONE_SHOT)
	Steam.joinLobby(int(%RoomCodeInput.text))
	%JoinWithCodeButton.disabled = false

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		SteamUser.lobby_id = lobby_id
		_go_to_room()
	elif response == Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
		%Popup.popup(tr("@ROOM_NOT_EXIST"), PopupDialog.Type.INFORMATION)			
	elif response == Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
		%Popup.popup(tr("@ROOM_JOIN_FAILED_FULL"), PopupDialog.Type.INFORMATION)	
	else:
		%Popup.popup(tr("@ROOM_JOIN_FAILED"), PopupDialog.Type.INFORMATION)			

func _go_to_room():
	AudioPlayer.stop_music(MAIN_THEME_AUDIO, true)
	get_tree().change_scene_to_file("res://scenes/online_battle/lobby/room/room.tscn")

var matchmaking_loop_count = 0
const MAX_LOOP = 9
func _auto_matchmaking():
	if matchmaking_loop_count >= MAX_LOOP:
		%Popup.popup("@MATCHMAKING_FAILED", PopupDialog.Type.INFORMATION)
		Steam.lobby_match_list.disconnect(_on_matchmaking_lobby_match_list)
		Steam.lobby_joined.disconnect(_on_matchmaking_lobby_joined)
		matchmaking_loop_count = 0
		return
		
	if matchmaking_loop_count == 0:
		Steam.lobby_match_list.connect(_on_matchmaking_lobby_match_list)
		Steam.lobby_joined.connect(_on_matchmaking_lobby_joined)
		%Popup.popup("@FINDING", PopupDialog.Type.PROGRESS)
		
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	_apply_room_filter()
	Steam.requestLobbyList()
	
func _on_matchmaking_lobby_match_list(lobbies: Array):
	for lobby_id in lobbies:
		# TODO: remove true
		if true or Steam.getLobbyOwner(lobby_id) != SteamUser.STEAM_ID:
			Steam.joinLobby(lobby_id)
			await Steam.lobby_joined
	
	matchmaking_loop_count += 1
	_auto_matchmaking()
		
func _on_matchmaking_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		SteamUser.lobby_id = lobby_id
		_go_to_room()
		
func _check_Command_Line() -> void:
	var ARGUMENTS: Array = OS.get_cmdline_args()

	# There are arguments to process
	if ARGUMENTS.size() > 0:

		# A Steam connection argument exists
		if ARGUMENTS[0] == "+connect_lobby":

			# Lobby invite exists so try to connect to it
			if int(ARGUMENTS[1]) > 0:

				# At this point, you'll probably want to change scenes
				# Something like a loading into lobby screen
				print("CMD Line Lobby ID: "+str(ARGUMENTS[1]))
				Steam.joinLobby(int(ARGUMENTS[1]))
