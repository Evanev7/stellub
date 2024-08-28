extends Node
class_name StateMachine

@export var state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.connect("change_state", switch_state)
	
	if state:
		state.enter()


func _process(delta):
	for checking_state in states.keys():
		if states[checking_state].check_interrupt():
			switch_state(state, checking_state)
	if state:
		state.process(delta)

func _physics_process(delta):
	if state:
		state.physics_process(delta)

func switch_state(from_state: State, to_state: String):
	owner.sprite.animation = "boss"
	owner.blocking = false
	if from_state != state:
		return
	
	if state:
		state.exit()
	
	state = states[to_state.to_lower()]
	state.enter()
