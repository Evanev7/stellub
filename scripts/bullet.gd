extends Area2D

@export var speed: int = 400
@export var lifetime: int = 20
@export var bullet_range: int = 1000
@export var damage: int = 1
var direction: Vector2 = Vector2(0,0)
var _traveled_distance: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bullet")
	$SelfDestruct.wait_time = lifetime
	$SelfDestruct.start()
	rotation = direction.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var distance = speed * delta
	position += direction * distance
	
	_traveled_distance += distance
	if _traveled_distance > bullet_range:
		queue_free()


func _on_self_destruct_timeout():
	queue_free()


func _on_body_entered(body):
	if body != GameState.player:
		if body.has_method("hurt"):
			body.hurt(self)
		queue_free()
