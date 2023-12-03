extends State

func enter():
	change_state.emit(self, "randomizer")
	print("hi!!!!!")
