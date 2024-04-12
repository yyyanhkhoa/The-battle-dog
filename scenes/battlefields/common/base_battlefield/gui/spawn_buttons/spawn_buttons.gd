extends Control

@onready var first_row: HBoxContainer = $FirstRow
@onready var second_row: HBoxContainer = $SecondRow
@onready var switch_row_button: TextureButton = $SwitchRowButton

var done_tweening := true

func setup(dog_tower: BaseDogTower, player_data: BaseBattlefieldPlayerData):
	var name_ids: Array = player_data.team_dog_ids
	var id_index := 0
	var action_number = 1
	for button in $FirstRow.get_children():
		var name_id = name_ids[id_index]
		if name_id != null:
			button.setup(name_ids[id_index], "ui_spawn_%s" % action_number, true, dog_tower, player_data)
		
		id_index += 1	
		action_number += 1

	action_number = 1		
	for button in $SecondRow.get_children():
		var name_id = name_ids[id_index]
		if name_id != null:
			button.setup(name_ids[id_index], "ui_spawn_%s" % action_number, false, dog_tower, player_data)
		
		id_index += 1	
		action_number += 1
		
	$SwitchRowButton.pressed.connect(_switch_row)

func _switch_row() -> void:
	# do not switch row when is in tweening process
	if !done_tweening:
		return
	
	$SwitchRowButton.play_wait_animation()
	
	var back_row = get_child(0)
	var front_row = get_child(1)
	
	for button in front_row.get_children():
		button.set_active(false)

	for button in back_row.get_children():
		button.set_active(true)

	move_child(back_row, 1)
	
	var tween = create_tween()
	tween.set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	done_tweening = false
	tween.tween_property(front_row, "position", back_row.position, 0.2)
	tween.tween_property(back_row, "position", front_row.position, 0.2)
	tween.finished.connect(_on_donw_tweening)

func _on_donw_tweening() -> void:
	$SwitchRowButton.play_ready_animation()
	done_tweening = true
