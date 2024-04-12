extends Control

const ListItem = preload("res://scenes/upgrade/item_box.tscn")

const UNLOCK_AUDIO: AudioStream = preload("res://resources/sound/unlock.wav")
const UPGRADE_AUDIO: AudioStream = preload("res://resources/sound/upgrade.mp3")

var TutorialDogScene: PackedScene = preload("res://scenes/upgrade/upgrade_tutorial_dog/upgrade_tutorial_dog.tscn")

var character_data 
var skill_data 
var selected_item: ItemUpgradeBox
var last_selected_item_character: ItemUpgradeBox
var last_selected_item_skill: ItemUpgradeBox
var last_selected_item_passive: ItemUpgradeBox

var dog_boxes: Array[ItemUpgradeBox]
var skill_boxes: Array[ItemUpgradeBox]
var passive_boxes: Array[ItemUpgradeBox]

func _ready():
	%NutNangCap.disabled = true
	%TabContainer.set_tab_title(0, tr("@CHARACTERS"))
	%TabContainer.set_tab_title(1, tr("@SKILLS"))
	%TabContainer.set_tab_title(2, tr("@PASSIVES"))
	%TabContainer.tab_changed.connect(func(tab: int):
		var options = [last_selected_item_character, last_selected_item_skill, last_selected_item_passive]
		update_ui(options[tab]) 
	)
		
	add_items()
	selected_item = dog_boxes[0]
	last_selected_item_character = dog_boxes[0]
	last_selected_item_skill = skill_boxes[0]
	last_selected_item_passive = passive_boxes[0]
	
	# show first item
	update_ui(selected_item)
	
	if not Data.has_done_upgrade_tutorial:
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		tutorial_dog.tree_exited.connect(func(): canvas.queue_free())


const DEFAULT_DOGS = ["dog", "waffle_dog", "sword_dog", "angel_dog", "sniper_dog"]
func add_items():
	var type := ItemUpgradeBox.Type
	
	for data in Data.dog_info.values():	
		# only show upgrade box of a dog if it is unlockable by default or if player already has the dog
		if not DEFAULT_DOGS.has(data['ID']) and not Data.dogs.has(data['ID']):
			continue 
				
		var dog_item_box := createItemBox(type.CHARACTER, data, %NhanVat/MarginContainer/GridContainer)
		dog_boxes.append(dog_item_box)
		
	for data in Data.skill_info.values():			
		var skill_item_box := createItemBox(type.SKILL, data, %Skill/MarginContainer/GridContainer)
		skill_boxes.append(skill_item_box)

	for data in Data.passive_info.values():			
		var passive_item_box := createItemBox(type.PASSIVE, data, %Passives/MarginContainer/GridContainer)
		passive_boxes.append(passive_item_box)

func sendInfo(item: ItemUpgradeBox):
	$click.play()
	update_ui(item)

func update_ui(item: ItemUpgradeBox):
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	
	var type := item.get_item_type() 
	if type == ItemUpgradeBox.Type.SKILL:
		last_selected_item_skill = selected_item
	elif type == ItemUpgradeBox.Type.CHARACTER:
		last_selected_item_character = selected_item
	else:
		last_selected_item_passive = selected_item
	
	%ItemName.text = item.get_item_name()
	%ItemDescription.text = item.get_item_description()
	
	%NutNangCap.text = tr("@UPGRADE") if selected_item.get_level() > 0 else tr("@UNLOCK") 
		
	%NutNangCap.disabled = selected_item.get_price() > Data.bone or selected_item.get_level() >= 10 
	
func createItemBox(type: ItemUpgradeBox.Type, data: Dictionary, container: GridContainer) -> ItemUpgradeBox:
	var item = ListItem.instantiate()
	item.setup(type, data, self)
	container.add_child(item)
	return item


func reupdate_current_ui():
	selected_item.update_labels()
	%NutNangCap.disabled = selected_item.get_price() > Data.bone or selected_item.get_level() >= 10 
	%NutNangCap.text = tr("@UPGRADE")

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	Data.bone -= selected_item.get_price()
	
	var type := selected_item.get_item_type() 
	var item_id := selected_item.get_item_id()
	
	if selected_item.get_level() > 0:
		AudioPlayer.play_sfx(UPGRADE_AUDIO)
		if type == ItemUpgradeBox.Type.SKILL:
			Data.skills[item_id]['level'] += 1
		elif type == ItemUpgradeBox.Type.CHARACTER:
			Data.dogs[item_id]['level'] += 1
		else:
			Data.passives[item_id]['level'] += 1
	
	else: 
		AudioPlayer.play_sfx(UNLOCK_AUDIO)
		var item = {"ID": item_id, "level": 1}
		if  type == ItemUpgradeBox.Type.SKILL:
			Data.save_data["skills"].append(item)
		elif type == ItemUpgradeBox.Type.CHARACTER:
			Data.unlock_dog(item_id)
		else:
			Data.save_data["passives"].append(item)
	
	Data.save()
	reupdate_current_ui()
