extends Control

const ScoreItem = preload("ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var list_index1 = 0
var list_index2 = 0
var list_index0 = 0
# Replace the leaderboard name if you're not using the default leaderboard
var ld_name = "main"
var max_scores = 10
var sw_fastest_time
var sw_high_scores
var sw_victory_count
var number = 10
func _ready():		
	self.set_process_mode(4) 
	$VBoxContainer/Control/TabContainer.set_tab_title(0, tr("@HIGHSCORE"))
	$VBoxContainer/Control/TabContainer.set_tab_title(1, tr("@FASTESTTIME"))	
	$VBoxContainer/Control/TabContainer.set_tab_title(2, tr("@VICTORYCOUNT"))	
	
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
	add_loading_scores_message()
	sw_high_scores = await SilentWolf.Scores.get_scores(0,"high_scores").sw_get_scores_complete
	sw_fastest_time = await SilentWolf.Scores.get_scores(0,"fastest_time").sw_get_scores_complete
	sw_victory_count = await SilentWolf.Scores.get_scores(0,"victory_count").sw_get_scores_complete
	self.set_process_mode(0) 
	hide_message()
	render_board(sw_high_scores.scores,number,0)
	render_board(sw_fastest_time.scores,number,1,true)	
	render_board(sw_victory_count.scores,number,2)
	load_description(0)
	
	if sw_high_scores.scores.is_empty() == true:	
		add_no_scores_message()
	

func _on_tab_container_tab_changed(tab):
	hide_message()
	if (tab == 0) and (sw_high_scores.scores.is_empty() == true):
		add_no_scores_message()		
	if (tab == 1) and (sw_fastest_time.scores.is_empty() == true):
		add_no_scores_message()
	if (tab == 2) and (sw_victory_count.scores.is_empty() == true):
		add_no_scores_message()
	load_description(tab)

func render_board(scores : Array ,numb : int, local_scores: int, time: bool = false) -> void:
	var list_score = scores
	if time == false :
		for score in list_score.slice(0,numb):
			add_item(score.player_name, score.score,local_scores)			
	else : #add time scores
		list_score.reverse()
		for score in list_score.slice(0,numb):
			add_time_item(score.player_name, score.score)

#Show ranking
func add_item(player_name: String, score_value: int, tab: int) -> void:
	var item = ScoreItem.instantiate()
	item.get_node("Score").text = str(score_value)
	if tab == 0 :
		list_index0 += 1
		item.get_node("PlayerName").text = str(list_index0) + str(". ") + player_name
		item.offset_top = list_index0 * 100
		$VBoxContainer/Control/TabContainer/HighScores/MarginContainer/ScoreItemContainer.add_child(item)
	elif tab == 2:
		list_index2 += 1
		item.get_node("PlayerName").text = str(list_index2) + str(". ") + player_name
		item.offset_top = list_index2 * 100
		$"VBoxContainer/Control/TabContainer/VictoryCount/MarginContainer/ScoreItemContainer".add_child(item)

func add_time_item(player_name: String, score_value: int) -> void:
	var item = ScoreItem.instantiate()
	list_index1+= 1
	item.get_node("PlayerName").text = str(list_index1) + str(". ") + player_name
	item.get_node("Score").text =str(int(score_value/60),":",(score_value-(int(score_value/60) * 60)))
	item.offset_top = list_index1 * 100
	$"VBoxContainer/Control/TabContainer/FastestTime/MarginContainer/ScoreItemContainer".add_child(item)
	
func add_no_scores_message() -> void:
	var item = $VBoxContainer/Control/MessageContainer/TextMessage
	item.text = "No scores yet!"
	$VBoxContainer/Control/MessageContainer.show()

func add_loading_scores_message() -> void:	
	var item = $VBoxContainer/Control/MessageContainer/TextMessage
	item.text = "Loading scores..."
	$VBoxContainer/Control/MessageContainer.show()
	
func hide_message() -> void:
	$VBoxContainer/Control/MessageContainer.hide()

func load_description(tab : int):
	if (tab == 0):
		$VBoxContainer/MarginContainer/ItemDescription.text = tr("@HIGHSCORE_DESCRIPTION")
	elif (tab == 1):
		$VBoxContainer/MarginContainer/ItemDescription.text = tr("@FASTESTTIME_DESCRIPTION")
	elif (tab == 2):
		$VBoxContainer/MarginContainer/ItemDescription.text = tr("@VICTORYCOUNT_DESCRIPTION")

#func clear_leaderboard() -> void:	
#	var score_item_container = $"VBoxContainer/Control/TabContainer/High Scores/MarginContainer/ScoreItemContainer"
#	if score_item_container.get_child_count() > 0:
#		var children = score_item_container.get_children()
#		for c in children:
#			score_item_container.remove_child(c)
#			c.queue_free()
