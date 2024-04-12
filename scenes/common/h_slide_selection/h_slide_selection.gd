class_name HSlideSelection extends SubViewportContainer

signal item_focus(item: Selectable)

var _items: Array[Selectable] 
func get_items() -> Array[Selectable]: return _items

var _prev_selected_item: Selectable
var _selected_item: Selectable
func get_selected_item() -> Selectable: return _selected_item

var _hovered: bool = false
var _always_listen: bool
var _in_focus: bool = false

func _ready() -> void:
	mouse_entered.connect(func(): _hovered = true)
	mouse_exited.connect(func(): _hovered = false)

## always listen: if true, listen to user input even if not focusing. 
## if false, will only listen when focus
func setup(items: Array[Selectable], selected_item_index: int, always_listen: bool = false):
	_always_listen = always_listen
	_items = items
	for i in range(items.size()):
		var item := items[i]

		item.pressed.connect(_on_item_pressed.bind(item))
		item.focus_entered.connect(focus.bind(i))
		var control := Control.new()
		control.custom_minimum_size = item.size
		item.resized.connect(func(): control.custom_minimum_size = item.size)
		control.add_child(item)
		%HBoxContainer.add_child(control)
				
	_selected_item = items[selected_item_index]
	
	## setup item navigation
	ready.connect(func():
		for i in range(items.size()):
			var item = items[i]
			var item_path := item.get_path()	
			
			var left_path := items[i - 1].get_path() if i > 0 else item_path
			item.focus_neighbor_left = left_path
			item.focus_previous = left_path
					
			var right_path := items[i + 1].get_path() if i < items.size() - 1 else item_path
			item.focus_neighbor_right = right_path
			item.focus_next = right_path
	)
	
	# wait for stage boxes name to be loaded in (which will change the size of HBox)
	%HBoxContainer.sort_children.connect(func():
		custom_minimum_size.y = items[0].size.y * 1.2
		%HBoxContainer.position.y = custom_minimum_size.y * 0.2 * 0.5
		_selected_item.grab_focus()
	, CONNECT_ONE_SHOT)	
	
	focus_entered.connect(func(): 
		_selected_item.grab_focus()
	)
	
func _on_item_pressed(item: Selectable):
	if _prev_selected_item != item:
		focus_by_item(item)

func focus_by_item(item: Selectable) -> void:
	if _prev_selected_item == item:
		return
		
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_selected_item, "scale", Vector2(1, 1), 0.2)
	
	_selected_item.handle_local_focus_exited()
	_selected_item = item
	_selected_item.grab_focus()
	_selected_item.handle_local_focus_entered()
	
	tween.tween_property(_selected_item, "scale", Vector2(1.1, 1.1), 0.2)
	
	tween.tween_property(%HBoxContainer, "position:x", _get_x_of(_selected_item), 0.5)
	
	item_focus.emit(_selected_item)
	_prev_selected_item = item

func focus(index: int) -> void:
	focus_by_item(_items[index])

func _get_x_of(stage_box: Selectable):
	var box_position = stage_box.get_parent().position + (stage_box.size / 2)
	return -box_position.x + (size.x / 2)

func _input(ev: InputEvent):
	if _always_listen and not _selected_item.has_focus():
		_handle_navigation_input(ev)
	
	if _always_listen or _selected_item.has_focus():
		_handle_selection_input(ev)	
		
	_handle_swipe_input(ev)

var swiping = false
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []
var _is_a_press: bool = false
var _drag_distance := Vector2.ZERO
var _skip: int = 0

func _handle_swipe_input(ev: InputEvent) -> void:
	if swiping == false and not _hovered:
		return
	
	if ev is InputEventMouseButton:
		if ev.double_click:
			return
		
		if _skip > 0:
			_skip -= 1
			return
		
		if ev.pressed:
			_is_a_press = true
			swiping = true
			swipe_mouse_start = ev.position
			swipe_mouse_times = [Time.get_ticks_msec()]
			swipe_mouse_positions = [swipe_mouse_start]
			
			# avoid focusing on item when swiping
			get_viewport().set_input_as_handled()
		else:
			if _is_a_press:
				_skip = 2
				var event = InputEventMouseButton.new()
				event.button_index = ev.button_index
				## dont fucking ask why u have to do this, idk either. something to do with black bars
				event.position = ev.global_position
				event.pressed = true
				Input.parse_input_event(event)	
				var event2 = InputEventMouseButton.new()
				event2.button_index = ev.button_index
				event2.position = ev.global_position
				Input.parse_input_event(event2)	
			
			swipe_mouse_times.append(Time.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source = Vector2(%HBoxContainer.position.x, %HBoxContainer.position.y)
			var idx = swipe_mouse_times.size() - 1
			var now = Time.get_ticks_msec()
			var cutoff = now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start = swipe_mouse_positions[idx]
			var flick_dur = min(0.3, (ev.position - flick_start).length() / 500)
			if flick_dur > 0.0:
				var tween = create_tween()
				var delta = ev.position - flick_start
				var target = source + delta * flick_dur * 25.0
				target.x = _x_clamp(target.x)
				
				tween.set_trans(Tween.TRANS_SINE)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_method((
					func(x): %HBoxContainer.position.x = x
				), source.x, target.x, flick_dur)
				tween.play()
			
			swiping = false
				
	elif swiping and ev is InputEventMouseMotion:
		%HBoxContainer.position.x += ev.relative.x
		%HBoxContainer.position.x = _x_clamp(%HBoxContainer.position.x)
		swipe_mouse_times.append(Time.get_ticks_msec())
		swipe_mouse_positions.append(ev.position)
		
		_drag_distance += ev.relative.abs()
		if _drag_distance.length() > Global.TOUCH_EPSISLON:
			_is_a_press = false
		
func _handle_navigation_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_selected_item.grab_focus()

func _handle_selection_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_confirm") or event.is_action_pressed("ui_confirm_default"):
		_selected_item.handle_selected()

func _x_clamp(x: float) -> float:
	return clamp(x, _get_x_of(_items[-1]), _get_x_of(_items[0]))

