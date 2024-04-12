@tool
extends FSMState

@onready var character: Character = owner
var wait_to_die = false
# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.get_node("AnimationPlayer").play("move")

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func physics_update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
	
	# kiem tra va cham
	var collider = character.n_RayCast2D.get_collider()
	if collider == null: #ko va cham
		character.velocity.x = character.speed * character.move_direction 
		
	else:# va cham				
		if (collider is CatTower) and (wait_to_die == false):
			wait_to_die = true
			start_die()
		
	character.move_and_slide() 

func start_die():
	$TimeToDie.start()

func _on_time_to_die_timeout():
	character.take_damage(99999999)
