extends State

var timer: float = 0
var dash_count: float = 0
var cur_player_direction: Vector2
@export var dash_windup: float = 0.4
@export var dash_duration: float = 1
@export var dash_speed: float = 1000
@export var num_dashes: int = 3

func enter():
	target_player()
	dash_count = 0
	timer = 0

func target_player():
	cur_player_direction = (GameState.player.position - owner.position).normalized()

func physics_process(delta):
	timer = (timer + delta) 
	if timer < dash_windup:
		owner.velocity = Vector2(0,0)
	elif timer > dash_windup + dash_duration:
		timer -= dash_windup + dash_duration
		target_player()
		dash_count += 1
		if dash_count >= num_dashes:
			change_state.emit(self, "randomizer")
	else:
		owner.velocity = cur_player_direction * dash_speed
