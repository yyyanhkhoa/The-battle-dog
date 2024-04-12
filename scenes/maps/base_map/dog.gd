extends AnimatedSprite2D

var current_stage: Stage
var stage_queue: Array[Stage]
var tween: Tween
var tween_duration: float

func _ready() -> void:
	play("default")

func setup(selected_stage: Stage, tracker: Tracker):
	current_stage = selected_stage
	global_position = current_stage.global_position + current_stage.pivot_offset
	tracker.move_stage.connect(_on_move_stage)
	
func _on_move_stage(target_stage: Stage):
	if target_stage == current_stage:
		stage_queue = []
		return
		
	var prev_stages: Array[Stage] = []
	var next_stages: Array[Stage] = []
	
	var prev := current_stage.prev_stage
	var next := current_stage.next_stage
	
	while(prev != null or next != null):
		if prev != null:
			prev_stages.append(prev)
			if prev != target_stage:
				prev = prev.prev_stage
			else:
				break
			
		if next != null:
			next_stages.append(next)
			if next != target_stage:
				next = next.next_stage
			else:
				break
	
	stage_queue = prev_stages if prev == target_stage else next_stages
	tween_duration = 0.5 / (1 + (stage_queue.size() - 1) * 0.5)
	
	if tween == null or !tween.is_running():
		moving()
	
func moving():
	var stage: Stage = stage_queue.pop_front()
	if stage == null:
		return

	scale.x = abs(scale.x) if stage.global_position.x > current_stage.global_position.x else -abs(scale.x) 
	current_stage = stage
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", stage.global_position + stage.pivot_offset, tween_duration)
	tween.tween_callback(moving)
	
	
