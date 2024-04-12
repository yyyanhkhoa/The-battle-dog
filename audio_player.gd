extends Node

# preloaded audio
const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/button_pressed.mp3")

## contain players and related data like tween node and playback position 
var _music_players: Dictionary = {} 
var _in_battle_sfx_players: Dictionary = {} 
var _current_music: AudioStream

## get currently playing music
func get_current_music() -> AudioStream: return _current_music

func _ready() -> void:
	process_mode =  PROCESS_MODE_ALWAYS
		
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	
	Data.sound_fx_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(sound_fx_idx, linear_to_db(value / 100.0))
	)
	Data.music_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(music_idx, linear_to_db(value / 100.0))
	)
	Data.mute_music_changed.connect(
		func(mute: bool): 
			AudioServer.set_bus_mute(music_idx, mute)
	)
	Data.mute_sound_fx_changed.connect(
		func(mute: bool): 
			AudioServer.set_bus_mute(sound_fx_idx, mute)
	)

func _create_music_player_data(audio: AudioStream) -> Dictionary:
	var music_player := _create_music_audio_player(audio) 
	add_child(music_player)
	return {
		"tween": create_tween(),
		"player": music_player,
		"playback_position": 0.0
	}

func _create_music_audio_player(audio: AudioStream) -> AudioStreamPlayer:
	var music_player := AudioStreamPlayer.new()
	music_player.stream = audio
	music_player.bus = "Music"
	return music_player
	
func _create_sfx_audio_player(audio: AudioStream) -> AudioStreamPlayer:
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SoundFX"
	sfx_player.stream = audio
	return sfx_player

func play_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0):
	var sfx_player = _create_sfx_audio_player(audio_stream)
	sfx_player.pitch_scale = pitch_scale
	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()
	
func play_music(audio_stream: AudioStream, resume: bool = false, with_transition: bool = false):
	if not _music_players.has(audio_stream.resource_path):
		_music_players[audio_stream.resource_path] = _create_music_player_data(audio_stream)
	
	_current_music = audio_stream
	
	var music_data: Dictionary = _music_players[audio_stream.resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
			
	var tween: Tween = music_data['tween']
	
	if not with_transition:
		tween.kill()
	else:		
		tween.pause()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(music_player, "volume_db", 0, 0.25)
		music_data['tween'] = tween
	
	# music is not fully stopped yet (still being in fade out transition)
	if resume and music_player.playing:
		return
	
	if resume:
		music_player.play(music_data['playback_position'])
	else:
		music_player.play()
		
	music_player.finished.connect(
		func():
			_current_music = null
			remove_music(audio_stream)
	, CONNECT_ONE_SHOT)
	
func stop_music(audio_stream: AudioStream, with_transition: bool = false, remove_when_done: bool = false, stop_duration: float = 0.5):
	if audio_stream == null:
		return
	
	var audio_resource_path := audio_stream.resource_path
	if audio_resource_path == _current_music.resource_path:
		_current_music = null
		
	var music_data: Dictionary = _music_players[audio_resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
	var tween: Tween = music_data['tween']
	
	if not with_transition:
		tween.kill()
	else:		
		tween.pause()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_CIRC)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(music_player, "volume_db", -80, stop_duration)
		music_data['tween'] = tween
				
		await tween.finished
	
	## if music player has been erased (via using remove_all_music)
	if not is_instance_valid(music_player):
		return
		
	if remove_when_done:
		music_player.stop()	
		remove_music(audio_stream)
	else:
		music_player.stop()	
		music_data['playback_position'] = music_player.get_playback_position()

func stop_current_music(with_transition: bool = false, remove_when_done: bool = false, stop_duration: float = 0.5):
	if get_current_music() != null:
		stop_music(get_current_music(), with_transition, remove_when_done, stop_duration)
	
## remove music data from memory (this includes playback position and audio player).
## only call this method when music is already stop
func remove_music(audio_stream: AudioStream) -> void:
	if _music_players.get(audio_stream.resource_path) != null:
		_music_players[audio_stream.resource_path]['player'].queue_free()
		_music_players.erase(audio_stream.resource_path)

func remove_all_music() -> void:
	for music_data in _music_players.values():
		music_data['player'].queue_free()
		
	_music_players.clear()

func get_random_pitch_scale() -> float:
	return randf_range(0.85, 1.15)

func _create_in_battle_sfx(bus_name: String, no_compressor: bool = false) -> AudioStreamPlayer:
	var sfx_player = AudioStreamPlayer.new()
	
	if no_compressor:
		sfx_player.bus = "InBattleFX"
	else:
		sfx_player.bus = bus_name
		var index := AudioServer.bus_count
		AudioServer.add_bus(index)
		AudioServer.set_bus_name(index, bus_name)
		var compressor = AudioEffectCompressor.new()
		compressor.ratio = 1.5;
		compressor.gain = 2.0;
		compressor.threshold = -16.0;
		compressor.attack_us = 0.0;
		AudioServer.add_bus_effect(index, compressor)
		AudioServer.set_bus_send(index, "InBattleFX")
		
		sfx_player.tree_exited.connect(func(): 
			var bus_index = AudioServer.get_bus_index(bus_name)
			AudioServer.remove_bus(bus_index)
		)
		
	
	return sfx_player

func add_in_battle_sfx(audio_stream: AudioStream, max_polyphony: int = 1, no_compressor: bool = false) -> void:
	if has_in_battle_sfx(audio_stream):
		var sfx_player: AudioStreamPlayer = _in_battle_sfx_players[audio_stream.resource_path]
		sfx_player.max_polyphony = max_polyphony
		return
		
	var sfx_player := _create_in_battle_sfx(audio_stream.resource_path, no_compressor)
	sfx_player.stream = audio_stream
	sfx_player.max_polyphony = max_polyphony
	add_child(sfx_player)
	
	_in_battle_sfx_players[audio_stream.resource_path] = sfx_player

func has_in_battle_sfx(audio_stream: AudioStream) -> bool:
	return _in_battle_sfx_players.has(audio_stream.resource_path)

## If sfx is not added, auto add the sfx with max_polyphony = 10 [br]
## to set custom max_polyphony, use the add_in_battle_sfx function
func play_in_battle_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0, no_compressor: bool = false) -> void:
	if not _in_battle_sfx_players.has(audio_stream.resource_path):
		add_in_battle_sfx(audio_stream, 10, no_compressor)
	
	var sfx_player: AudioStreamPlayer = _in_battle_sfx_players[audio_stream.resource_path]
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()

## play and then remove sfx instead of storing it for later uses. use this for one-time sfx [br]
## no_compressor to avoid using the compressor effect, which may make the sfx sounds louder
func play_in_battle_sfx_once(audio_stream: AudioStream, pitch_scale: float = 1.0, no_compressor: bool = false) -> void:
	var sfx_player := _create_in_battle_sfx(audio_stream.resource_path, no_compressor)
	sfx_player.stream = audio_stream
	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()

## Remove sfx when it is no longer needed
func remove_in_battle_sfx(audio_stream: AudioStream) -> void:
	_in_battle_sfx_players[audio_stream.resource_path].queue_free()
	_in_battle_sfx_players.erase(audio_stream.resource_path)

func remove_all_in_battle_sfx() -> void:
	for audio_player in _in_battle_sfx_players.values():
		audio_player.queue_free()
		
	_in_battle_sfx_players.clear()
