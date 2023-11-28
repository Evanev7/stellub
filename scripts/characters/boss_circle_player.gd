extends State

@export var target_range = 800
@export var orbit_speed = 200

var current_range

func physics_process(_delta):
	var diff: Vector2 = (owner.position - GameState.player.position)
	current_range = diff.length()
	var movement_direction = orbit_speed * diff.rotated(PI/2) - diff * (current_range - target_range)
	owner.velocity = movement_direction.normalized() * orbit_speed
