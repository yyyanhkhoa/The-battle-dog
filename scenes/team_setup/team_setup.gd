extends Control

const ListCharacter = preload("res://scenes/team_setup/box_character.tscn")
const TutorialDogScene: PackedScene = preload("res://scenes/team_setup/team_setup_tutorial_dog/team_setup_tutorial_dog.tscn")

var character_id_to_item: Dictionary
var skill_id_to_item: Dictionary
var store_id_to_item: Dictionary
@onready var character_slots: Array[Node] = %CharacterSlots.get_children()
@onready var skill_slots: Array[Node] = %SkillSlots.get_children()
@onready var store_slots: Array[Node] = %StoreSlots.get_children() 

func _ready():		
	%TabContainer.set_tab_title(0, tr("@CHARACTERS"))
	%TabContainer.set_tab_title(1, tr("@SKILLS"))
	%TabContainer.set_tab_title(2, tr("@ITEMS"))
	%TabContainer.tab_changed.connect(_on_tab_container_tab_changed)
	
	# Thiết lập nhân vật và kỹ năng
	loadCharacterList()
	loadSkillList()
	loadStoreList()
	# đưa đội hình hiện tại vào teams	6
	loadTeam()
	
	if not Data.has_done_team_setup_tutorial:
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		tutorial_dog.tree_exited.connect(func(): canvas.queue_free())
	
func loadCharacterList() -> void:
	for dog_id in Data.dogs:
		var item := create_item(dog_id, SelectCharacterBox.Type.CHARACTER)
		%CharacterList.add_child(item)
		character_id_to_item[dog_id] = item
		item.pressed.connect(_on_add_character_to_slot.bind(item))

func loadSkillList() -> void:
	for data in Data.skills.values():
		var item := create_item(data['ID'], SelectCharacterBox.Type.SKILL)
		%SkillList.add_child(item)
		skill_id_to_item[data['ID']] = item
		item.pressed.connect(_on_add_skill_to_slot.bind(item))

func loadStoreList() -> void:
	for data in Data.store.values():
		if data['amount'] > 0 :
			print(data)
			var item := create_item(data['ID'], SelectCharacterBox.Type.STORE)
			%StoreList.add_child(item)
			store_id_to_item[data['ID']] = item
			item.pressed.connect(_on_add_store_to_slot.bind(item))

func _on_add_character_to_slot(item: SelectCharacterBox):
	for slot in character_slots:
		if slot.get_item_type() == SelectCharacterBox.Type.NONE:
			slot.change_item(item.get_item_id(), SelectCharacterBox.Type.CHARACTER) 
			item.visible = false
			save_team_setup()
			return
	
func _on_add_skill_to_slot(item: SelectCharacterBox):
	for slot in skill_slots:
		if slot.get_item_type() == SelectCharacterBox.Type.NONE:
			slot.change_item(item.get_item_id(), SelectCharacterBox.Type.SKILL) 
			item.visible = false
			save_team_setup()
			return
			
func _on_add_store_to_slot(item: SelectCharacterBox):
	for slot in store_slots:
		if slot.get_item_type() == SelectCharacterBox.Type.NONE:
			slot.change_item(item.get_item_id(), SelectCharacterBox.Type.STORE) 
			item.visible = false
			save_team_setup()
			return
func create_item(item_id: String, type: SelectCharacterBox.Type) -> SelectCharacterBox:
	var item = ListCharacter.instantiate()
	item.setup(item_id, type)
	return item
		
func loadTeam() -> void:
	for i in range(10):
		var slot := character_slots[i] 
		var character_id = Data.selected_team['dog_ids'][i]
		if character_id == null:
			slot.clear()
		else:
			slot.change_item(character_id, SelectCharacterBox.Type.CHARACTER)
			character_id_to_item[character_id].visible = false

		slot.pressed.connect(_on_remove_character_from_slot.bind(slot))
	
	for i in range(3):
		var slot := skill_slots[i] 
		var skill_id = Data.selected_team['skill_ids'][i]
		if skill_id == null:
			slot.clear()
		else:
			slot.change_item(skill_id, SelectCharacterBox.Type.SKILL)
			skill_id_to_item[skill_id].visible = false
		
		slot.pressed.connect(_on_remove_skill_from_slot.bind(slot))
	
	for i in range(3):
		var slot := store_slots[i] 
		var store_id = Data.selected_team['store_ids'][i]
#		print(Data.store[store_id] 
		if store_id == null :
			slot.clear()
		elif (Data.store[store_id]['amount'] <1) :
			print(slot)
			slot.clear()
			
		else:
			slot.change_item(store_id, SelectCharacterBox.Type.STORE)
			store_id_to_item[store_id].visible = false

		slot.pressed.connect(_on_remove_store_from_slot.bind(slot))
func _on_remove_character_from_slot(slot: SelectCharacterBox):
	if slot.get_item_type() != SelectCharacterBox.Type.NONE:
		character_id_to_item[slot.get_item_id()].visible = true
		slot.clear()
		save_team_setup()
	
func _on_remove_skill_from_slot(slot: SelectCharacterBox):
	if slot.get_item_type() != SelectCharacterBox.Type.NONE:
		skill_id_to_item[slot.get_item_id()].visible = true
		slot.clear()
		save_team_setup()
		
func _on_remove_store_from_slot(slot: SelectCharacterBox):
	if slot.get_item_type() != SelectCharacterBox.Type.NONE:
		store_id_to_item[slot.get_item_id()].visible = true
		slot.clear()
		save_team_setup()
	
func save_team_setup():	
	Data.selected_team['dog_ids'] = character_slots.map(func(item: SelectCharacterBox): return item.get_item_id())
	Data.selected_team['skill_ids'] = skill_slots.map(func(item: SelectCharacterBox): return item.get_item_id())
	Data.selected_team['store_ids'] = store_slots.map(func(item: SelectCharacterBox): return item.get_item_id())
	Data.save()

func move(a) :
	$Luu.play()
	if (a == 1):
		$Khung/PhanDuoi/DanhSach/Skill.visible = false
		$Khung/PhanDuoi/DanhSach/Store.visible = false
		$Khung/PhanDuoi/DanhSach/NhanVat.visible = true
	elif (a == 2) :
		$Khung/PhanDuoi/DanhSach/Store.visible = false
		$Khung/PhanDuoi/DanhSach/Skill.visible = true
		$Khung/PhanDuoi/DanhSach/NhanVat.visible = false
	else :
		$Khung/PhanDuoi/DanhSach/Skill.visible = false
		$Khung/PhanDuoi/DanhSach/Store.visible = true
		$Khung/PhanDuoi/DanhSach/NhanVat.visible = false

func _on_tab_container_tab_changed(tab: int):
	if (tab == 0) :
		move(1)
	elif (tab == 1) :
		move(2)
	else :
		move(3)
