extends StaticBody2D

var velocity = Vector2(0, 0)
var speed = 300
var timer = 0

func _ready():
	add_to_group("bullet")

func _physics_process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)
	
	if timer < 400:
		timer += 1
	else:
		queue_free()
		timer = 0


func _on_area_2d_body_entered(body):
	if body.name == "PlayerTopDown":
		pass
	else:
		queue_free()
	pass
