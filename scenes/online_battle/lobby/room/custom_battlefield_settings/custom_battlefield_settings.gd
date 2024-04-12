class_name CustomBattlefieldSettings extends PanelContainer

signal settings_changed(type: String, value: Variant)

const DEFAULT_STAGE_WIDTH: int = 3000 
const DEFAULT_DOG_TOWER_HEALTH: int = 5000 
const DEFAULT_EFFICIENCY_LEVEL: int = 10 
const DEFAULT_POWER_LEVEL: int = 10
const DEFAULT_MUSIC: String = "battlefield_theme1" 
const DEFAULT_THEME: String = "green_grass" 

const TYPE_STAGE_WIDTH := "stage_width"
const TYPE_DOG_TOWER_HEALTH := "dog_tower_health"
const TYPE_MONEY_EFFICIENCY_LEVEL := "efficiency_level"
const TYPE_POWER_LEVEL := "power_level"
const TYPE_MUSIC := "music"
const TYPE_THEME := "theme"
const TYPES: Array[String] = [
		TYPE_STAGE_WIDTH, TYPE_DOG_TOWER_HEALTH, TYPE_MONEY_EFFICIENCY_LEVEL,
		TYPE_POWER_LEVEL, TYPE_MUSIC, TYPE_THEME
]

const MUSIC_CODE_TO_NAME := {
	"battlefield_theme1": "キミにあげる！",
	"battlefield_theme2": "ちゃっかり七兵衛",
	"battlefield_theme3": "イクスゲイナー",
	"battlefield_theme_rush1": "Cat and Mouse Rag",
	"battlefield_theme_rush2": "渇き",
	"battlefield_theme_nightmare": "堕天",
	"battlefield_theme_heavenly": "終焉の音",
	"boss_theme1": "戦闘準備中",
	"boss_theme2": "捕まえろ！",
	"boss_theme3": "ハクギン"
}

const THEMES := ["green_grass", "fall", "winter", "heavenly", "night", "nightmare"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%StageWidthSlider.value_changed.connect(_on_value_changed.bind(%StageWidthValue, TYPE_STAGE_WIDTH))
	%TowerHealthSlider.value_changed.connect(_on_value_changed.bind(%TowerHealthValue, TYPE_DOG_TOWER_HEALTH))
	%MoneyEfficiencySlider.value_changed.connect(_on_value_changed.bind(%MoneyEfficiencyValue, TYPE_MONEY_EFFICIENCY_LEVEL))
	%PowerSlider.value_changed.connect(_on_value_changed.bind(%PowerValue, TYPE_POWER_LEVEL))
	
	%StageWidthValue.text = str(DEFAULT_STAGE_WIDTH)
	%TowerHealthValue.text = str(DEFAULT_DOG_TOWER_HEALTH)
	%MoneyEfficiencyValue.text = str(DEFAULT_EFFICIENCY_LEVEL)
	%PowerValue.text = str(DEFAULT_POWER_LEVEL)
	%MusicLabel.text = "%s: " % tr("@MUSIC")
	%ThemeLabel.text = "%s: " % tr("@THEME")
	%MusicName.text = MUSIC_CODE_TO_NAME[DEFAULT_MUSIC]
	%ThemeName.text = tr("@THEME_%s" % DEFAULT_THEME)
	
	var song_names := MUSIC_CODE_TO_NAME.values()
	var music_order: int = 1
	for music_code in MUSIC_CODE_TO_NAME:
		%MusicOptions.add_item("%s - %s" % [music_order, MUSIC_CODE_TO_NAME[music_code]])
		music_order += 1
	
	for theme in THEMES:
		%ThemeOptions.add_item(tr("@THEME_%s" % theme))
		
	%MusicOptions.item_selected.connect(_on_music_selected)
	%ThemeOptions.item_selected.connect(_on_theme_selected)

func set_editable(editable: bool) -> void:
	%StageWidthSlider.editable = editable
	%TowerHealthSlider.editable = editable
	%MoneyEfficiencySlider.editable = editable
	%PowerSlider.editable = editable
	%MusicOptions.visible = editable
	%ThemeOptions.visible = editable
	%MusicName.visible = !editable
	%ThemeName.visible = !editable
	
func _on_value_changed(value: float, target: Label, type: String) -> void:
	settings_changed.emit(type, value)
	target.text = str(value)

func _on_music_selected(index: int) -> void:
	settings_changed.emit(TYPE_MUSIC, MUSIC_CODE_TO_NAME.keys()[index])

func _on_theme_selected(index: int) -> void:
	settings_changed.emit(TYPE_THEME, THEMES[index])

# set settings (but will not emit settings_changed)
func set_settings(type: String, value: Variant) -> void:
	if type == TYPE_STAGE_WIDTH:
		%StageWidthSlider.set_value_no_signal(value)
		%StageWidthValue.text = str(value)
	elif type == TYPE_DOG_TOWER_HEALTH:
		%TowerHealthSlider.set_value_no_signal(value)
		%TowerHealthValue.text = str(value)
	elif type == TYPE_MONEY_EFFICIENCY_LEVEL:
		%MoneyEfficiencySlider.set_value_no_signal(value)
		%MoneyEfficiencyValue.text = str(value)
	elif type == TYPE_POWER_LEVEL:
		%PowerSlider.set_value_no_signal(value)
		%PowerValue.text = str(value)
	elif type == TYPE_MUSIC:
		var index: int = MUSIC_CODE_TO_NAME.keys().find(value)
		%MusicOptions.select(index)
		%MusicName.text = MUSIC_CODE_TO_NAME[value] 
	elif type == TYPE_THEME:
		var index: int = THEMES.find(value)
		%ThemeOptions.select(index)
		%ThemeName.text = tr("@THEME_%s" % value) 
