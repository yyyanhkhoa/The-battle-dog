extends CanvasLayer

var _debug_mode := false 
var _draw_debug := false 
var _debug_label: Label

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_debug_mode = OS.is_debug_build()
	
		
func _ready() -> void:
	set_process(false)
	
	if not _debug_mode:
		set_process_input(false)
	
	if _debug_mode:
		var canvas := CanvasLayer.new()
		canvas.layer = 9
		_debug_label = Label.new()
		_debug_label.position = Vector2(180, 180)
		_debug_label.add_theme_font_size_override("font_size", 20)
		_debug_label.add_theme_color_override("font_outline_color", Color.DARK_GREEN)
		_debug_label.add_theme_constant_override("outline_size", 6)
		canvas.add_child(_debug_label)
		add_child(canvas)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_draw_debug'):
		_draw_debug = !_draw_debug
		_debug_label.text = ""   
		set_process(_draw_debug)
		
		for node in get_tree().get_nodes_in_group('characters'):
			node.queue_redraw()

	if event.is_action_pressed('ui_debug_speed'):
		Engine.time_scale = 10 if Engine.time_scale == 1 else 1
	
	if event.is_action_pressed('ui_debug_battlefield_money'):
		var battlefield = get_tree().current_scene
		if battlefield is BaseBattlefield:
			var player_data: BaseBattlefieldPlayerData = battlefield.get_player_data()
			for i in range(player_data.MAX_EFFICIENCY_LEVEL - player_data.get_efficiency_level()):
				player_data.increase_efficiency_level()
			
			player_data.fmoney = player_data.get_wallet_capacity()
	
	if event.is_action_pressed('ui_debug_save_file'):
		Data.passed_stage = 99
		Data.bone = 999999999
		Data.save()
		
	if event.is_action_pressed('ui_debug_switch_language'):
		TranslationServer.set_locale("en" if TranslationServer.get_locale() == "vi" else "vi")	

	if event.is_action_pressed('ui_debug_kill_cats'):
		for cat in get_tree().get_nodes_in_group("cats"):
			cat.take_damage(999999999)

	if event.is_action_pressed('ui_debug_win_battle'):
		InBattle.get_battlefield()._win()
	
func _process(delta: float) -> void:
	_debug_label.text = "FPS: %s\n" % Engine.get_frames_per_second()    
	
	var timer_pool := Global._delta_timer_pool as DeltaTimerPool
	_debug_label.text += "shared_timers: %s/%s\n" % [
		timer_pool._shared_timers.size(), (timer_pool._shared_timers.size() + timer_pool._unused_timers.size())
	]
	
	if not InBattle.get_battlefield() is BaseBattlefield:
		return
	
	_debug_label.text += "Total Bullets %s/%s\n" % [
		Bullets.get_total_active_bullets(), 
		Bullets.get_total_active_bullets() + Bullets.get_total_available_bullets()
	] 
		
	_debug_label.text += "Characters: %s\n" % get_tree().get_nodes_in_group("characters").size()
	
	var fx_hit_pool := InBattle._fx_hit_pool as FxHitPool 
	_debug_label.text += "Hit Fxs: %s/%s\n" % [
		fx_hit_pool._fx_hits.size(), 
		fx_hit_pool._fx_hits.size() + fx_hit_pool._unused_fx_hits.size()
	]
		
	var danamku_space := InBattle.get_danmaku_space()
	for kit in danamku_space.bullet_kits:
		_debug_label.text += "%s: %s/%s\n" % [
			kit.resource_name, 
			Bullets.get_active_bullets(kit),
			Bullets.get_active_bullets(kit) + Bullets.get_available_bullets(kit)
	]

func is_debug_mode() -> bool:
	return _debug_mode

func is_draw_debug() -> bool:
	return _draw_debug
