extends State

@export var target_range = 700
@export var orbit_speed = 400
@export var min_duration: float = 5
@export var max_duration: float = 10

var current_range: float
var timer: float = 0
var duration: float

func enter():
	timer = 0
	duration = randf_range(min_duration,max_duration)

func physics_process(delta):
	timer += delta
	var diff: Vector2 = (owner.position - GameState.player.position)
	current_range = diff.length()
	var movement_direction = orbit_speed * diff.rotated(PI/2) - diff * (current_range - target_range)
	owner.velocity = movement_direction.normalized() * orbit_speed
	
	if timer > duration:
		change_state.emit(self, "randomizer")
