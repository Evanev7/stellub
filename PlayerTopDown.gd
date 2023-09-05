extends CharacterBody2D

const SPEED = 200.0
var Bullet = preload("res://Bullet.tscn")
var timer = 0


func _physics_process(delta):
	if timer < 3:
		timer += 1
	else:
		shoot()
		timer = 0
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var hori_direction = Input.get_axis("left", "right")
	var vert_direction = Input.get_axis("up", "down")
	if hori_direction or vert_direction:
		velocity.x = hori_direction * SPEED
		velocity.y = vert_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	$Node2D.look_at(get_global_mouse_position())


func shoot():
	var bullet = Bullet.instantiate()
	get_parent().add_child(bullet)
	
	bullet.position = $Node2D/Marker2D.global_position
	bullet.velocity = get_global_mouse_position() - bullet.position

