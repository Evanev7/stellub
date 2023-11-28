extends State

var available_states = [
	"circleplayer",
	"driveby"
]

func enter():
	change_state.emit(self, available_states[randi_range(0,available_states.size() - 1)])
