extends CanvasLayer
## this node will start the game when everyone has load the battlefield and is ready 

func _init() -> void:
	Steam.lobby_data_update.connect(_start_game_when_all_is_ready)
	Steam.lobby_joined.connect(_on_lobby_joined)

func _ready() -> void:
	ready.connect(func(): get_tree().paused = true, CONNECT_ONE_SHOT)
	%Popup.popup("@WAITTING_FOR_OTHER_PLAYER_IN_BATTLE", PopupDialog.Type.PROGRESS)
	SteamUser.set_lobby_member_data("in_battle_ready", "true")

	# rejoin and send in case of bad internet
	$InBattleReadyResendTimer.timeout.connect(
		func(): 
			Steam.joinLobby(SteamUser.lobby_id)
	)
	
func _on_lobby_joined(_lobby_id: int, _permissions: int, _locked: bool, _response: int) -> void:
	SteamUser.set_lobby_member_data("in_battle_ready", "true")
	
	var is_everyone_ready = SteamUser.players.all(func(player):
		return SteamUser.get_member_data(player['steam_id'], "in_battle_ready") == "true"
	)
	
	SteamUser.set_lobby_member_data('received_ready_message', "true" if is_everyone_ready else "false")

func _start_game_when_all_is_ready(success: int, lobby_id: int, member_id: int) -> void:
	if member_id == lobby_id:
		return
	
	var everyone_readied_and_received_message = SteamUser.players.all(func(player):
		return (
			SteamUser.get_member_data(player['steam_id'], "in_battle_ready") == "true"
			and SteamUser.get_member_data(player['steam_id'], "received_ready_message") == "true"
		)
	)
	
	if everyone_readied_and_received_message:
		if is_node_ready():
			_start_game()
		else:
			ready.connect(_start_game, CONNECT_ONE_SHOT)

func _start_game():
	get_tree().paused = false
	Steam.lobby_joined.disconnect(_on_lobby_joined)
	Steam.lobby_data_update.disconnect(_start_game_when_all_is_ready)
	$InBattleReadyResendTimer.stop()
	%Popup.close()
	queue_free()
