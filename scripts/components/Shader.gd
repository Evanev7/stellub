extends Sprite2D

@export var shader_activation: float = 1.0
@export var lifetime_timer: Timer
@export var timer_map: Curve

var shutdown = 0.2
var begin_shutdown = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not begin_shutdown:
		material.set_shader_parameter("activator", timer_map.sample(lifetime_timer.time_left / lifetime_timer.wait_time))
	elif shutdown > 0:
		shutdown -= delta
		material.set_shader_parameter("activator", shutdown**2)
