extends CanvasLayer

signal surrendered

const MAX_POPUP_WIDTH: int = 700

func _ready() -> void:
	if %PopupPanel.get_minimum_size().x >= MAX_POPUP_WIDTH:
		%WarningMessage.text = ""
		%WarningMessage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		%PopupPanel.size.x = MAX_POPUP_WIDTH
		%WarningMessage.text = tr("@SURRENDER_WARNING")
		%PopupPanel.anchors_preset = Control.PRESET_CENTER
		%SurrenderLabel.position.y = %PopupPanel.position.y - %SurrenderLabel.pivot_offset.y
	
	%SurrenderButton.pressed.connect(func(): surrendered.emit())
	%CancelButton.pressed.connect(func(): 
		hide()
	)
