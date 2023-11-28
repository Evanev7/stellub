extends EnemyBehaviour

signal give_me_data(who)

@export var finite_state_machine: Node

func _physics_process(_delta):
	move_and_slide()
