extends Area2D

signal credit_player(value)

@export var launch_angle: float = PI/6
@export var launch_velocity: float = 250
@export var activation_time: float = 2
@export var grav_scale: float = 5
@export var speed: float = 3

var value: int = 1

var activated: bool = false
var lifetime: float = 0
var velocity: float = 0

func _ready():
	#Randomly distribute launch_angle according to proper distribution
	$AnimatedSprite2D.play()
	launch_angle = (randi_range(0,1)*2-1)*acos(1-randf()*(1-cos(launch_angle)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	lifetime += delta
	if lifetime < activation_time:
		var direction = Vector2.from_angle(launch_angle- PI/2)
		position += launch_velocity * direction * delta + Vector2(0,lifetime*grav_scale)
	if activated:
		var direction = (GameState.player.position - position).normalized()
		velocity += speed
		position += velocity * direction * delta
	

func _on_self_destruct_timeout():
	queue_free() # Replace with function body.


func _on_area_entered(area):
	if area.owner == GameState.player:
		credit_player.emit(value)
	queue_free()


func _on_activation_range_entered(area):
	if area.owner == GameState.player:
		activated = true
