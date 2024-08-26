extends Node
class_name State

@warning_ignore("unused_signal")
signal change_state(from_state, to_state)

func enter():
	pass

func exit():
	pass

func process(_delta):
	pass

func physics_process(_delta):
	pass

func check_interrupt() -> bool:
	return false
