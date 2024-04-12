class_name SkillButton extends Button

var skill_id: String
var spawn_input_action: String
var spawn_time: float

var is_active: bool
var _dog_tower: BaseDogTower

func is_spawn_ready() -> bool:
	return $SpawnTimer.is_stopped()

func can_spawn():
	return is_spawn_ready() and is_active

func setup(skill_id: String, input_action: String, is_active: bool, dog_tower: BaseDogTower) -> void:
	_dog_tower = dog_tower
	self.skill_id = skill_id
	set_active(is_active)
	spawn_input_action = input_action
	
	$Icon.texture = load("res://resources/images/skills/%s_icon.png" % skill_id)
	
	spawn_time = Data.skill_info[skill_id]['spawn_time']
	$SpawnTimer.wait_time = spawn_time 
	$SpawnTimer.timeout.connect(_on_spawn_ready)
	
	pressed.connect(_on_pressed)
	$AnimationPlayer.play("ready")
	set_process(true)
	set_process_input(true)
	
func set_active(active: bool) -> void:
	is_active = active
	self.disabled = !active
	
func _ready() -> void:
	$Background.frame = 1
	$ProgressBar.visible = false
	$AnimationPlayer.play("empty")
	set_process(false)
	set_process_input(false)

func _on_spawn_ready() -> void:
	$ProgressBar.visible = false
	self.disabled = not can_spawn()
	$Background.frame = 0 if can_spawn() else 1	

func _on_pressed() -> void:
	spawn_skill()
	
func spawn_skill():
	_dog_tower.use_skill(skill_id)
	_start_recharge_ui()
	
func _start_recharge_ui() -> void:
	self.disabled = true
	$ProgressBar.visible = true
	$Background.frame = 1
	$SpawnTimer.start()

func _process(delta: float) -> void:
	if $ProgressBar.visible:
		var elapsed_time = spawn_time - $SpawnTimer.time_left	
		
		var tween = create_tween()
		var value = tween.interpolate_value(
			0.0, 100.0, elapsed_time, spawn_time, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		$ProgressBar.value = value
		tween.kill()
	
	self.disabled = not can_spawn()
	$Background.frame = 0 if can_spawn() else 1	
