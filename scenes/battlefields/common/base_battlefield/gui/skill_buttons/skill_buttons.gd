extends Control

var done_tweening := true

func setup(dog_tower: BaseDogTower, player_data: BaseBattlefieldPlayerData):
	var skill_ids: Array = player_data.team_skill_ids
	var id_index := 0
	var action_number = 1
	
	for button in $FirstRow.get_children():		
		var name_id = skill_ids[id_index]
		if name_id != null:
			button.setup(skill_ids[id_index], "ui_skill_%s" % action_number, true, dog_tower)
		
		id_index += 1	
		action_number += 1	
