@tool
extends MainGUI

func _ready() -> void:
	if not Engine.is_editor_hint():
		go_back_scene_path = "res://scenes/maps/%s_map/%s_map.tscn" % [Data.selected_chapter_id, Data.selected_chapter_id]

	super._ready()
	
