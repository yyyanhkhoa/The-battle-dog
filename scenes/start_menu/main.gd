extends Control

const MAIN_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/main_theme.mp3")
const SettingsScene: PackedScene = preload("res://scenes/settings/settings.tscn")
const CreditsScene: PackedScene = preload("res://scenes/credits/credits.tscn")

var _settings: Settings = null
var _credits: Credits = null
@onready var popup: = $Popup as PopupDialog

func _ready():
	AudioPlayer.play_music(MAIN_THEME_AUDIO)
	get_tree().set_auto_accept_quit(false)
	if SteamUser.IS_USING_STEAM and SteamUser.is_logged_on():
		%OnlinePlayButton.disabled = false
		%OnlinePlayButton.pressed.connect(_go_to_lobby)
	else:
		%OnlinePlayButton.disabled = true
		%OnlinePlayButton.tooltip_text = "@NEED_LOGGED_IN_WITH_STEAM"
		
	$AnimationPlayer.play("ready")
	await $AnimationPlayer.animation_finished
	
	%SettingsButton.pressed.connect(_go_to_settings)
	%CreditButton.pressed.connect(_go_to_credits)
	
	if Global.is_host_OS_web():
		%QuitButton.visible = false
	else:		
		%QuitButton.pressed.connect(_quit_game)
	
func _process(delta: float) -> void:
	if Data.select_data == true:
		Data.select_data = false
		show_select_data_box()	
		set_process(false)

func show_select_data_box():
	if Data.data_notifi == true:		
		Data.data_notifi = false
		$ConfirmationDialog.show()	

func _on_nut_bat_dau_pressed():
	AudioPlayer.stop_music(MAIN_THEME_AUDIO, true, true)
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _quit_game():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	if Data.use_sw_data == true :
			Data.save_data = Data.old_data
			SilentWolf.Players.save_player_data(Data.save_data.user_name, Data.save_data)
	await get_tree().create_timer(1).timeout 
	get_tree().quit()

func _go_to_credits():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	if (_credits == null):
		_credits = _create_credit()
		get_parent().add_child(_credits)
		
	self.hide()
	_credits.show()
	
func _create_credit() -> Credits:
	var credits: Credits = CreditsScene.instantiate()
	
	credits.goback_pressed.connect(func(): 
		self.show()
		credits.hide()
	)
	
	self.tree_exiting.connect(credits.queue_free)	
	
	return credits
	
func _go_to_settings():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	if (_settings == null):
		_settings = _create_settings()	
		get_parent().add_child(_settings)
		
	self.hide()
	_settings.show()

func _create_settings() -> Settings:
	var settings: Settings = SettingsScene.instantiate()
	
	settings.goback_pressed.connect(func(): 
		self.show()
		settings.hide()
	)
	
	self.tree_exiting.connect(settings.queue_free)
	
	return settings

func _go_to_lobby():
	get_tree().change_scene_to_file("res://scenes/online_battle/lobby/lobby.tscn")



func _on_confirmation_dialog_canceled():
	popup.popup(tr("@LOADING"), PopupDialog.Type.PROGRESS)
	var sw_result = await SilentWolf.Players.get_player_data(Data.silentwolf_data.user_name).sw_get_player_data_complete
	Data.save_data = sw_result.player_data
	Data.silentwolf_data = sw_result.player_data
	Data.use_sw_data = true
	Data.save()
	SteamUser.sw_dangky.emit()
	popup.close()


func _on_confirmation_dialog_confirmed():
	popup.popup(tr("@LOADING"), PopupDialog.Type.PROGRESS)
	var sw_result = await SilentWolf.Players.get_player_data(Data.silentwolf_data.user_name).sw_get_player_data_complete
	var user_name = Data.silentwolf_data["user_name"]
	Data.silentwolf_data = Data.save_data
	await SilentWolf.Players.save_player_data(user_name, Data.silentwolf_data)
	Data.save()
	SteamUser.sw_dangky.emit()
	popup.close()
