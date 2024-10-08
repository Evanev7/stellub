extends State

var timer: float = 0
var dash_count: float = 0
var cur_player_direction: Vector2
@export var dash_windup: float = 0.4
@export var dash_duration: float = 1
@export var dash_speed: float = 1000
@export var num_dashes: int = 3
@onready var dash = $Dash

func enter():
	target_player()
	dash_count = 0
	timer = 0
	owner.attack_handler.stop()

func target_player():
	cur_player_direction = (GameState.player.position - owner.position).normalized()

func physics_process(delta):
	timer = (timer + delta) 
	if timer < dash_windup:
		dash.play()
		owner.attack_handler.start()
		owner.velocity = Vector2(0,0)
	elif timer > dash_windup + dash_duration:
		timer -= dash_windup + dash_duration
		target_player()
		dash_count += 1
		owner.attack_handler.start()
		if dash_count >= num_dashes:
			change_state.emit(self, "randomizer")
	else:
		owner.velocity = cur_player_direction * dash_speed
		#owner.attack_handler.stop()
