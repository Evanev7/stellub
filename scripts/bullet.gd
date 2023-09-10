extends Area2D

@onready var data: BulletResource

var direction: Vector2 = Vector2(0,0)
var origin
var _traveled_distance: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bullet")
	if origin == GameState.player:
		set_collision_layer(4)
	else:
		set_collision_layer(2)
	
	$SelfDestruct.wait_time = data.lifetime
	$SelfDestruct.start()
	rotation = direction.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _traveled_distance > data.bullet_range:
		queue_free()
	
	var distance = data.speed * delta
	position += direction * distance
	
	_traveled_distance += distance

func _on_self_destruct_timeout():
	queue_free()
