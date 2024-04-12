extends Node

var _popup: PopupDialog
var game_ended: bool = false

# client side variables
var _reconnecting_connection_handle: int
var _client_connection_closed_by_server: bool = false

func _init() -> void:
	var is_server: bool = SteamUser.players[0]['steam_id'] == SteamUser.STEAM_ID
	
	if is_server:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_server)
	else:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_client)
		
func setup(popup: PopupDialog) -> void:
	$ReconnectTimer.timeout.connect(_on_reconnect_timeout)
	_popup = popup

func _on_network_connection_status_changed_server(connection_handle: int, connection: Dictionary, old_state: int):
	var new_state: int = connection['connection_state']
	# example: steamid:76561199486434807" -> 76561199486434807
	var steam_id: int = int(connection['identity'].get_slice(":", 1))
	var username: String = Steam.getFriendPersonaName(steam_id)
	print("old_state-------")
	print(old_state)
	print(connection)
	print("old_state-------")
	
	# opponent trying to reconnect, accept connection
	var is_player_in_battle = SteamUser.players.filter(
		func(player): return player['steam_id'] == steam_id
	).size() > 0
	
	if (
		new_state == Steam.CONNECTION_STATE_CONNECTING
		and is_player_in_battle 
	):
		get_tree().paused = false
		print("SERVER: ACCEPT CONNECTION %s" % connection_handle)
		Steam.acceptConnection(connection_handle)
		SteamUser.connection_handle = connection_handle
		$ReconnectTimer.stop()
		_popup.close()
		return
	
	## only accept connection when game ended and nothing else	
	if game_ended:
		return
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	if old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED:
		print("SERVER: connection re-established.")
		return
		
	# failed to connect
	if new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("SERVER: failed to connect with peer")
		SteamUser.close_connection(connection_handle)
		
		if $ReconnectTimer.is_stopped():
			get_tree().paused = true
			$ReconnectTimer.start()
			
			_popup.popup_process(
				func(): return "%s %s... (%s)" % [
					tr("@RECONNECTING_WITH"), username, int($ReconnectTimer.time_left)
				],
				PopupDialog.Type.PROGRESS
			)

		if new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
			get_tree().paused = true
			print("SERVER: connection closed by peer")
			SteamUser.close_connection(connection_handle)
			_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
			await _popup.ok
			get_tree().paused = false
			(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
		
func _on_reconnect_timeout():
	var is_server: = SteamUser.is_lobby_owner()

	if is_server:
		SteamUser.set_lobby_data("game_status", "waiting")
		Steam.network_connection_status_changed.disconnect(_on_network_connection_status_changed_server)
		_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
		await _popup.ok
		get_tree().paused = false
		(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
	else:
		if _client_connection_closed_by_server:
			_client_handle_server_close_connection(_reconnecting_connection_handle)
		else:
			_client_handle_reconnect_failed(_reconnecting_connection_handle)

func _client_handle_reconnect_failed(connection_handle) -> void:
		Steam.network_connection_status_changed.disconnect(_on_network_connection_status_changed_client)
		_popup.popup("@RECONNECT_FAILED", PopupDialog.Type.INFORMATION)
		await _popup.ok
		get_tree().paused = false
		Steam.leaveLobby(SteamUser.lobby_id)
		SteamUser.lobby_id = 0
		var opponent_id = InBattle.get_opponent_data().get_steam_id()
		(InBattle.get_battlefield() as P2PBattlefield).end_game(opponent_id)
		
func _on_network_connection_status_changed_client(connection_handle: int, connection: Dictionary, old_state: int):
	_reconnecting_connection_handle = connection_handle
	
	print("==========")
	print(connection)
	print("==========")
	var new_state: int = connection['connection_state']
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	# connection accepted
	if old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED:
		print("CLIENT: connection re-established.")
		_client_handle_connection_reestablished(connection_handle)
		return
			
	# disconnected, reconnecting
	if ( 
		new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY 
		or new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER
	):
		# this is either server close the connection or client has bad internet speed,
		# therefore retry to connect again, if not working then that means server has close the connection
		if new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
			_client_connection_closed_by_server = true
			
		print("CLIENT: disconnected, reconnecting...")
		
		SteamUser.close_connection(connection_handle)
		_reconnect_to_listen_socket()
		
		# show reconnecting message
		if $ReconnectTimer.is_stopped():
			get_tree().paused = true
			$ReconnectTimer.start()
			_popup.popup_process(func():
				return "%s (%s)" % [tr("@RECONNECTING"), int($ReconnectTimer.time_left)]
			, PopupDialog.Type.PROGRESS)
					
func _client_handle_connection_reestablished(connection_handle: int) -> void:
	get_tree().paused = false
	$ReconnectTimer.stop()
	_popup.close()
	SteamUser.connection_handle = connection_handle
	
	## rejoin lobby
	Steam.joinLobby(SteamUser.lobby_id)
	Steam.lobby_joined.connect(_on_lobby_rejoined, CONNECT_ONE_SHOT)

func _on_lobby_rejoined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	SteamUser.update_lobby_members()
		
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS or SteamUser.lobby_members.has(SteamUser.STEAM_ID):
		# check if game has ended
		var winner := SteamUser.get_lobby_data("winner")
		print(winner)
		if winner != "":
			(InBattle.get_battlefield() as P2PBattlefield).end_game(int(winner))
	else:
		Steam.leaveLobby(SteamUser.lobby_id)
		SteamUser.lobby_id = 0
		SteamUser.close_connection(SteamUser.connection_handle)
		_popup.popup("@GAME_LOST_CONNECTION", PopupDialog.Type.INFORMATION)	
		await _popup.ok	
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/online_battle/lobby/lobby.tscn")
		
func _client_handle_server_close_connection(connection_handle: int) -> void:
	print("CLIENT: connection closed, owner left.")
	SteamUser.close_connection(connection_handle)
	
	# leave lobby (in case where server did not close conenction but due to bad internet)
	Steam.leaveLobby(SteamUser.lobby_id)
	SteamUser.lobby_id = 0
	
	_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
	await _popup.ok
	get_tree().paused = false
	(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
	return

## returns connection_handler
func _reconnect_to_listen_socket() -> void:
	var server_id: int = SteamUser.players[0]['steam_id']
	print("CONNECTING TO LISTEN SOCKET of lobby: %s, owner: %s" % [SteamUser.lobby_id, server_id])
	Steam.clearIdentity("room_owner")
	Steam.addIdentity("room_owner")
	Steam.setIdentitySteamID64("room_owner", server_id)
	Steam.connectP2P("room_owner", 0, [])	

func handle_game_ended() -> void:
	var is_server: bool = SteamUser.players[0]['steam_id'] == SteamUser.STEAM_ID
	
	## server still need to handle client connecting requests
	if is_server:
		game_ended = true
	else:
		queue_free()
