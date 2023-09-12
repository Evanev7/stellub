extends Area2D

@onready var data: BulletResource
@onready var sprite = $AnimatedSprite2D
@onready var _traveled_distance: float = data.start_range

var direction: Vector2 = Vector2(0,0)
var origin_ref: WeakRef
var relative_position

var damage


# Called when the node enters the scene tree for the first time.
# Set some initial rotations, and set different collision layer for player and
# enemy bullets.
func _ready():
	add_to_group("bullet")
	if origin_ref.get_ref() == GameState.player:
		set_collision_mask(4)
	else:
		set_collision_mask(2)
	$AnimatedSprite2D.play()
	damage = data.damage
	sprite.sprite_frames = data.animation
	$SelfDestruct.wait_time = data.lifetime
	$SelfDestruct.start()
	rotation = direction.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var _direction = direction * data.shot_speed
	var origin = origin_ref.get_ref()
	if origin:
		if data.angular_velocity != 0:
			_direction += (position - origin.position).rotated(PI/2)*data.angular_velocity
		if data.shot_speed == 0:
			_direction += origin.velocity
		if _traveled_distance < 200:
			rotation = (position - origin.position).angle()
	position += _direction * delta
	_traveled_distance += data.shot_speed*delta
	
	
	if _traveled_distance > data.bullet_range:
		queue_free()

func _on_self_destruct_timeout():
	queue_free()

func _on_area_entered(area):
	area.owner.hurt(self)
	queue_free()
