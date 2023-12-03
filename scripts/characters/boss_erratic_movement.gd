extends State

var timer: float = 0
var dash_count: float = 0
var cur_direction: Vector2
var cur_duration
@export var dash_duration: float = 0.5
@export var dash_variance: float = 0.2
@export var dash_speed: float = 500
@export var rand_angle: float = 4./3. * PI
@export var num_dashes: int = 7

func enter():
	get_next_direction()
	dash_count = 0
	timer = 0

func get_next_direction():
	var cur_player_direction = (GameState.player.position - owner.position).normalized()
	cur_direction = cur_player_direction.rotated(randf_range(-rand_angle/2, rand_angle/2))
	cur_duration = dash_duration + randf_range(-dash_variance,dash_variance)

func physics_process(delta):
	timer = timer + delta
	if timer > cur_duration:
		timer -= cur_duration
		get_next_direction()
		owner.velocity = cur_direction * dash_speed
		dash_count += 1
		if dash_count >= num_dashes:
			change_state.emit(self, "randomizer")
