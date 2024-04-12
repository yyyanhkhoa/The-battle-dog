extends Node2D

@onready var stages = get_children()	

func _draw() -> void:
	for stage in Data.passed_stage:
		var vitri1 = stages[stage].position + stages[stage].pivot_offset 
		var vitri2 = stages[stage+1].position + stages[stage+1].pivot_offset 
		draw_dashed_line(vitri1,vitri2, Color.hex(0x79B2A3FF), 9, 12, true)
	
	if Data.passed_stage >= 0 and Data.passed_stage < (stages.size() - 1):
		var vitri1 = stages[Data.passed_stage].position + stages[Data.passed_stage].pivot_offset 
		var vitri2 = stages[Data.passed_stage+1].position + stages[Data.passed_stage+1].pivot_offset 
		draw_dashed_line(vitri1,vitri2, Color.hex(0x8d4949FF), 9, 12, true)
