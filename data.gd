extends Node

signal bone_changed(value: int)
signal music_volume_changed(value: int)
signal sound_fx_volume_changed(value: int)
signal mute_music_changed(mute: bool)
signal mute_sound_fx_changed(mute: bool)
var select_data: bool = false

var save_data: Dictionary
var silentwolf_data : Dictionary
var use_sw_data : bool
var data_notifi : bool:
	get: return true
	set(value): data_notifi = value
var user_name: String:
	get: return save_data['user_name']
	set(value): save_data['user_name'] = value

var date: String:
	get: return save_data['date']		
	set(value): save_data['date'] = value	

var bone: int:
	get: return save_data["bone"]
	set(value): 
		save_data["bone"] = value
		bone_changed.emit(value)		

var passed_stage: int:
	get: return save_data['chapters'][selected_chapter_id]['passed_stage']		
	set(value): save_data['chapters'][selected_chapter_id]['passed_stage'] = value		

var victory_count: int:
	get: return save_data['victory_count']
	set(value): save_data['victory_count'] = value

var fastest_time: int:
	get: return save_data['fastest_time']
	set(value): save_data['fastest_time'] = value
var online_score: int:
	get: return save_data['online_score']
	set(value): save_data['online_score'] = value
	
var selected_stage: int:
	get: return save_data['chapters'][Data.selected_chapter_id]['selected_stage']		
	set(value): save_data['chapters'][Data.selected_chapter_id]['selected_stage'] = value		

var selected_team: Dictionary:
	get: return teams[save_data['selected_team']]		
	set(value): teams[save_data['selected_team']] = value		

var teams: Array:
	get: return save_data['teams']		
	set(value): save_data['teams'] = value		

var selected_stage_id: String:
	get: return save_data['selected_stage_id']		
	set(value): save_data['selected_stage_id'] = value	

var sound_fx_volume: int:
	get: return save_data['settings']['sound_fx']['volume']		
	set(value): 
		save_data['settings']['sound_fx']['volume'] = value	
		sound_fx_volume_changed.emit(value)
		
var music_volume: int:
	get: return save_data['settings']['music']['volume']		
	set(value): 
		save_data['settings']['music']['volume'] = value	
		music_volume_changed.emit(value)

var mute_music: bool:
	get: return save_data['settings']['music']['mute']		
	set(value): 
		save_data['settings']['music']['mute'] = value	
		mute_music_changed.emit(value)	
		
var mute_sound_fx: bool:
	get: return save_data['settings']['sound_fx']['mute']		
	set(value): 
		save_data['settings']['sound_fx']['mute'] = value	
		mute_sound_fx_changed.emit(value)	
		
var game_language: String:
	get: return save_data['settings']['language']
	set(value): save_data['settings']['language'] = value	

var fullscreen: bool:
	get: return save_data['settings']['fullscreen']
	set(value): save_data['settings']['fullscreen'] = value	

var has_done_battlefield_basics_tutorial: bool:	
	get: return save_data['tutorial']['battlefield_basics']
	set(value): save_data['tutorial']['battlefield_basics'] = value

var has_done_battlefield_boss_tutorial: bool:
	get: return save_data['tutorial']['boss']
	set(value): save_data['tutorial']['boss'] = value

var has_done_battlefield_final_boss_tutorial: bool:
	get: return save_data['tutorial']['final_boss']
	set(value): save_data['tutorial']['final_boss'] = value

var has_done_battlefield_rush: bool:
	get: return save_data['tutorial']['battlefield_rush']
	set(value): save_data['tutorial']['battlefield_rush'] = value

var has_done_map_tutorial: bool:
	get: return save_data['tutorial']['map']
	set(value): save_data['tutorial']['map'] = value

var has_done_upgrade_tutorial: bool:
	get: return save_data['tutorial']['upgrade']
	set(value): save_data['tutorial']['upgrade'] = value
	
var has_done_team_setup_tutorial: bool:
	get: return save_data['tutorial']['team_setup']
	set(value): save_data['tutorial']['team_setup'] = value

var has_done_dogbase_tutorial: bool:
	get: return save_data['tutorial']['dogbase']
	set(value): save_data['tutorial']['dogbase'] = value

var has_done_dogbase_after_battlefield_tutorial: bool:
	get: return save_data['tutorial']['dogbase_after_battlefield']
	set(value): save_data['tutorial']['dogbase_after_battlefield'] = value

var selected_chapter_id: String:
	get: return save_data['selected_chapter_id']
	set(value): save_data['selected_chapter_id'] = value
	
var selected_chapter_dir_path: String:
	get: return save_data['selected_chapter_dir_path']
	set(value): save_data['selected_chapter_dir_path'] = value
	
var selected_story_id: String:
	get: return save_data['selected_story_id']
	set(value): save_data['selected_story_id'] = value

var dogs: Dictionary:
	get: return save_data['dogs']
	set(value): save_data['dogs'] = value


# auto generated data
# general info
var dog_info := Dictionary()
var cat_info := Dictionary()
var character_info := Dictionary()
var store_info := Dictionary()
var skill_info := Dictionary()
var passive_info := Dictionary()
var story_info := Dictionary()

var chapter_info: Dictionary:
	get: return story_info[selected_story_id][selected_chapter_id]

# save data
var skills := Dictionary()
var store := Dictionary()
var passives := Dictionary()

## this will be generated on entering a map.
## set to 999 for debuging purposes
var chapter_last_stage: int = 999

## count everytime player lost in a tutorial 
var tutorial_lost: int = 0 

var at_start_game_intro: bool = true

func _init() -> void:
	# if player opens game for the first time
	if not FileAccess.file_exists("user://save.json"):
		save_data = _create_new_game_save()
	else:
		save_data = _load_game_save()
	load_settings()

	var file := FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	var dog_info_arr = JSON.parse_string(file.get_as_text())
	for info in dog_info_arr:
		dog_info[info['ID']] = info
	file.close()
	
	file = FileAccess.open("res://resources/game_data/cats.json", FileAccess.READ)
	cat_info = JSON.parse_string(file.get_as_text())
	file.close()
	
	character_info = {}
	character_info.merge(dog_info)
	character_info.merge(cat_info)
	
	file = FileAccess.open("res://resources/game_data/skill.json", FileAccess.READ)
	var skill_info_arr = JSON.parse_string(file.get_as_text())
	for info in skill_info_arr:
		skill_info[info['ID']] = info
	file.close()
	
	file = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	var store_info_arr = JSON.parse_string(file.get_as_text())
	for info in store_info_arr:
		store_info[info['ID']] = info
	file.close()
	
	file = FileAccess.open("res://resources/game_data/passives.json", FileAccess.READ)
	var passive_info_arr = JSON.parse_string(file.get_as_text())
	for info in passive_info_arr:
		passive_info[info['ID']] = info
	file.close()
	
	file = FileAccess.open("res://resources/game_data/stories.json", FileAccess.READ)
	story_info = JSON.parse_string(file.get_as_text())
	file.close()
	
	compute_values()

func _create_new_game_save() -> Dictionary:
	var new_game_save_file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_save_data: Dictionary = JSON.parse_string(new_game_save_file.get_as_text())
	new_game_save_file.close()
	
	new_save_data.date = Time.get_datetime_string_from_system()
	var file = FileAccess.open("user://save.json", FileAccess.WRITE) 
	file.store_line(JSON.stringify(save_data))
	file.close()

	return new_save_data
	
func _load_game_save() -> Dictionary:
	var new_game_save_file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_game_save_data: Dictionary = JSON.parse_string(new_game_save_file.get_as_text())
	new_game_save_file.close()
	
	var file := FileAccess.open("user://save.json", FileAccess.READ)
	var save_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	## add date to save file if empty (this is to make overwriting save files easier)
	if not save_data.has("date"):
		save_data['date'] = Time.get_datetime_string_from_system()
	
	_compare_and_update_save_file(new_game_save_data, save_data)	
	_migrate_older_version_data(save_data)
	_compare_and_overwrite_save_data(new_game_save_data, save_data)
	
	file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()
	
	return save_data
	
## compare and update save data in case if the save data of an older version of the game
func _compare_and_update_save_file(new_game_save_data: Dictionary, save_data: Dictionary) -> void:	
	for key in new_game_save_data:
		if not save_data.has(key):
			save_data[key] = new_game_save_data[key]
			
		if typeof(save_data[key]) != typeof(new_game_save_data[key]):
			continue
			
		elif typeof(save_data[key]) == TYPE_DICTIONARY:
			_compare_and_update_save_file(new_game_save_data[key], save_data[key])
			
		elif typeof(save_data[key]) == TYPE_ARRAY and new_game_save_data[key].size() > 0:
			_compare_and_update_save_file_array(new_game_save_data[key][0], save_data[key])

func _compare_and_update_save_file_array(new_game_save_elem: Variant, save_data: Array) -> void:
	if new_game_save_elem == null:
		return 
		
	for i in range(save_data.size()):
		var elem = save_data[i]
		if elem == null:
			continue

		if typeof(elem) != typeof(new_game_save_elem):
			save_data[i] = new_game_save_elem
		
		elif typeof(elem) == TYPE_DICTIONARY:
			_compare_and_update_save_file(new_game_save_elem, elem)

func _migrate_older_version_data(save_data: Dictionary) -> void:
	## version <= 1.8 migration		
	if save_data.has("passed_level"):
		save_data["chapters"]["the_battle_dogs_rising"]["passed_stage"] = save_data["passed_level"]
		if save_data["passed_level"] == 12:
			save_data["chapters"]["the_battle_dogs_rising"]["completed"] = true
		save_data.erase("passed_level")
		
	if save_data.has("selected_level"):
		save_data["chapters"]["the_battle_dogs_rising"]["selected_stage"] = save_data["selected_level"]
		save_data.erase("selected_level")
	
	if save_data.has("selected_battlefield_id"):
		save_data["selected_stage_id"] = save_data["selected_battlefield_id"]
		save_data.erase("selected_battlefield_id")
		
	if typeof(save_data['dogs']) == TYPE_ARRAY:
		var new_dogs_data := {}
		for old_dog_data in save_data['dogs']:
			new_dogs_data[old_dog_data['ID']] = {'level': old_dog_data['level'], 'forms': ['normal'], "abilities": []}
			
		save_data['dogs'] = new_dogs_data

func _compare_and_overwrite_save_data(new_game_save_data: Dictionary, save_data: Dictionary) -> void:	
	for key in new_game_save_data:
		if typeof(save_data[key]) != typeof(new_game_save_data[key]):
			save_data[key] = new_game_save_data[key]
			
		elif typeof(save_data[key]) == TYPE_DICTIONARY:
			_compare_and_update_save_file(new_game_save_data[key], save_data[key])
			
		elif typeof(save_data[key]) == TYPE_ARRAY and new_game_save_data[key].size() > 0:
			_compare_and_update_save_file_array(new_game_save_data[key][0], save_data[key])

func _ready() -> void:	
	## if player opens the game for the first time (game_language is not chose yet)
	use_sw_data = false
	if game_language == "":	
		get_tree().change_scene_to_file("res://scenes/new_game_preferences/new_game_preferences.tscn")
	elif not Debug.is_debug_mode():
		get_tree().change_scene_to_file(
			"res://scenes/intros/%s_intro/%s_intro.tscn" % [selected_chapter_id, selected_chapter_id]
		)
	
	GlobalControl.set_fullscreen(fullscreen)
	
func compute_values():
	skills.clear()
	store.clear()
	passives.clear()
	
	for skill in save_data["skills"]:
		skills[skill["ID"]] = skill
	
	for item in save_data["store"]:
		store[item["ID"]] = item
	
	for passive in save_data["passives"]:
		passives[passive["ID"]] = passive

func save():
	save_data.date = Time.get_datetime_string_from_system()
	var file = FileAccess.open("user://save.json", FileAccess.WRITE) 
	file.store_line(JSON.stringify(save_data))
	file.close()
	
	compute_values()

func load_settings():
	TranslationServer.set_locale(game_language)	
	
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	
	AudioServer.set_bus_volume_db(sound_fx_idx, linear_to_db(sound_fx_volume / 100.0))
	AudioServer.set_bus_mute(sound_fx_idx, mute_sound_fx)
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume / 100.0))
	AudioServer.set_bus_mute(music_idx, mute_music)
	
	var key_overwrites: Dictionary = save_data['settings']['key_binding_overwrites']
	
	for action in key_overwrites.keys():
		var event = InputEventKey.new()
		event.keycode = key_overwrites[action]
		
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)	
	
func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if use_sw_data == true :
			SilentWolf.Players.save_player_data(save_data.user_name, save_data)
		await get_tree().create_timer(1).timeout 
		print("exit game")
		get_tree().quit()
	
func unlock_dog(dog_id: String) -> void:
	Data.dogs[dog_id] = { "abilities": [], "forms": ["normal"], "level": 1 }
