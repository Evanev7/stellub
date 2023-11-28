extends State

@export_range(0,10) var duration: float = 2.5
@export_range(1,5) var exponent: float = 2

var pathfollow: PathFollow2D
var timer: float = 0

# not currently getting data >:(
func _ready():
	owner.give_me_data.emit(self)

func thanks_for_the_data(path):
	pathfollow = path

func physics_process(delta):
	if pathfollow:
		timer += delta
		pathfollow.progress_ratio = (timer/duration)**exponent
		owner.position = pathfollow.position
		if timer >= duration:
			change_state.emit(self, "randomizer")

func enter():
	timer = 0

func exit():
	queue_free()
