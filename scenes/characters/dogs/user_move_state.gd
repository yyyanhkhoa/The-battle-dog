extends FSMState
@onready var character: Character = owner
# called when the state is activated
func enter(data: Dictionary):
	character.get_node("AnimationPlayer").play("move")
	$DiChuyen.play()

# (optional) called when the state is deactivated
func exit():
	pass 
		
# (optional) equivalent to _process but only called when the state is active
func update(delta:float)-> void:
	var direction = int(Input.is_action_pressed("ui_user_move_right")) - int(Input.is_action_pressed("ui_user_move_left"))
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		
	# kiem tra va cham
	var collider = character.n_RayCast2D.get_collider()
	if collider == null: #ko va cham
		if direction == 1 :	
			character.velocity.x = character.speed * character.move_direction * direction
		elif direction == -1 :
			character.velocity.x = character.speed * character.move_direction * direction
		else :
			character.velocity.x = 0
	else :
		if direction == 1 :
			character.velocity.x = 0
		elif direction == -1 :
			character.velocity.x = character.speed * character.move_direction * direction
		else :
			character.velocity.x = 0
	character.move_and_slide()  
	if Input.is_action_just_pressed("ui_user_attack") and character.n_AttackCooldownTimer.is_stopped():
		transition.emit("UserAttackState", { "target": collider })
	
# (optional) equivalent to _physics_process but only called when the state is active
func physics_update(delta):
	pass 

# (optional) equivalent of _input but only called when the state is active
func input(event: InputEvent):
	pass 
	
	

