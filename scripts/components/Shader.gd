extends Sprite2D

@export var shader_activation: float = 1.0
@export var lifetime_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var windup = lifetime_timer.time_left if lifetime_timer.time_left < shader_activation else 1.0
	material.set_shader_parameter("activator", windup**0.5)
