extends Control

const ListItem = preload("res://scenes/store/item_box.tscn")

const UNLOCK_AUDIO: AudioStream = preload("res://resources/sound/unlock.wav")
const UPGRADE_AUDIO: AudioStream = preload("res://resources/sound/upgrade.mp3")

var TutorialDogScene: PackedScene = preload("res://scenes/store/store_tutorial_dog/store_tutorial_dog.tscn")

var store_data 
var selected_item: ItemStoreBox
var last_selected_item_store: ItemStoreBox

var store_boxes: Array[ItemStoreBox]


func _ready():
	%NutNangCap.disabled = true
	%TabContainer.set_tab_title(0,tr("@STORE"))
		
	add_items()
	selected_item = store_boxes[0]
	last_selected_item_store = store_boxes[0]
	
	# show first item
	update_ui(selected_item)
	
	if not Data.has_done_upgrade_tutorial:
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		tutorial_dog.tree_exited.connect(func(): canvas.queue_free())
		
func add_items():
	var type := ItemStoreBox
	print(Data.store.values())
	for data in Data.store_info.values():		
		var store_item_box := createItemBox(data, %Item/MarginContainer/GridContainer)
		store_boxes.append(store_item_box)

func sendInfo(item: ItemStoreBox):
	$click.play()
	update_ui(item)

func update_ui(item: ItemStoreBox):
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	
	last_selected_item_store = selected_item
	
	%ItemName.text = item.get_item_name()
	%ItemDescription.text = item.get_item_description()
	
	%NutNangCap.disabled = selected_item.get_price() > Data.bone or selected_item.get_amount() >= 10 
	
func createItemBox(data: Dictionary, container: GridContainer) -> ItemStoreBox:
	var item = ListItem.instantiate()
	item.setup(data, self)
	container.add_child(item)
	return item

func reupdate_current_ui():
	selected_item.update_labels()
	%NutNangCap.disabled = selected_item.get_price() > Data.bone or selected_item.get_amount() >= 10 

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	Data.bone -= selected_item.get_price()
	
	var item_id := selected_item.get_item_id()
	
	if selected_item.get_amount() > 0:
		AudioPlayer.play_sfx(UPGRADE_AUDIO)
		Data.store[item_id]['amount'] += 1
	else: 
		AudioPlayer.play_sfx(UNLOCK_AUDIO)
		if Data.store.has(item_id):
			Data.store[item_id]['amount'] += 1
		else:		
			var item = {"ID": item_id, "amount": 1}
			Data.save_data["store"].append(item)
	
	Data.save()
	reupdate_current_ui()

