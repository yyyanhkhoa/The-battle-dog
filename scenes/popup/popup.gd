class_name PopupDialog extends CanvasLayer

signal ok
signal confirm
signal cancel

const MAX_POPUP_PANEL_WIDTH = 700

## Types of popup. [br]
## PROGRESS: no buttons, is used as a progress popup telling the player to wait
## INFORMATION: popup with an Ok button
## CONFIRMATION: popup with Yes and Cancel buttons 
enum Type { PROGRESS, INFORMATION, CONFIRMATION }

var _process_method: Callable

func _ready() -> void:
	set_process(false)
	set_process_shortcut_input(false)
	
	%OkButton.pressed.connect(func(): 
		self.hide()
		ok.emit()
	)
	
	%ConfirmButton.pressed.connect(func(): 
		self.hide()
		confirm.emit()
	)
	
	%CancelButton.pressed.connect(func(): 
		self.hide()
		cancel.emit()
	)
	
func _shortcut_input(event: InputEvent) -> void:
	#Stop event propagation
	get_viewport().set_input_as_handled()

func popup(message: String, popup_type: Type):
	set_process(false)
	set_process_shortcut_input(true)
	
	%OkButton.hide()
	%ConfirmationButtons.hide()
	
	if popup_type == Type.INFORMATION:
		%OkButton.show()
	elif popup_type == Type.CONFIRMATION:
		%ConfirmationButtons.show()
			
	set_message(message)
	
	self.show()
	
func set_message(message: String) -> void:
	%PopupMessage.autowrap_mode = TextServer.AUTOWRAP_OFF
	%PopupMessage.text = ""
	%PopupPanel.size.x = 0
	%PopupMessage.text = message
	
	# auto wrap text if popup panel exceed maxium size
	if %PopupPanel.get_minimum_size().x >= MAX_POPUP_PANEL_WIDTH:
		%PopupMessage.text = ""
		%PopupMessage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		%PopupPanel.size.x = MAX_POPUP_PANEL_WIDTH
		%PopupMessage.text = message
	
	%PopupPanel.position = Global.VIEWPORT_SIZE * 0.5 - %PopupPanel.size * 0.5
	
func popup_process(method: Callable, popup_type: Type) -> void:
	popup(method.call(), popup_type)
	
	set_process(true)
	_process_method = method

func _process(delta: float) -> void:
	if _process_method.is_valid():
		set_message(_process_method.call())

func close():
	self.hide()
