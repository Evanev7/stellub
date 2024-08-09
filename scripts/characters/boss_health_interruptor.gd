extends State

@onready var who = owner
var health_percent: float = 1
var cur_segment: float = 1
var divisions = [0.8, 0.6, 0.4, 0.2]

func check_interrupt() -> bool:
	if not divisions:
		return false
	health_percent = who.health/(who.resource.MAX_HP*who.overall_multiplier*who.unique_multiplier)
	if health_percent < divisions[0]:
		cur_segment = divisions.pop_front()
		return true
	
	return false

func enter():
	match cur_segment:
		0.8, 0.4:
			owner.attack_handler.start()
			change_state.emit(self, "terrainattack")
		0.6, 0.2:
			owner.attack_handler.start()
			change_state.emit(self, "anger")
