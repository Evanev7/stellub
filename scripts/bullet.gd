extends Area2D

signal fire_bullet(spawned_bullet: BulletResource)

@onready var data: BulletResource
@onready var spawned_bullet: BulletResource = data.spawned_bullet_resource
@onready var sprite = $AnimatedSprite2D
@onready var _traveled_distance: float = data.start_range

var piercing
var piercing_cooldown
var direction: Vector2 = Vector2(0,0)
var origin_ref: WeakRef
var prev_ref
var relative_position
var origin_position
var origin_velocity

var damage


# Called when the node enters the scene tree for the first time.
# Set some initial rotations, and set different collision layer for player and
# enemy bullets.
func _ready():
	if data.piercing:
		piercing = data.piercing
	add_to_group("bullet")
	piercing_cooldown = 0
	if origin_ref.get_ref() == GameState.player || prev_ref == "player":
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
	while piercing_cooldown > 0:
		piercing_cooldown -= 1
	if origin:
		origin_position = origin.position
		origin_velocity = origin.velocity
		if data.angular_velocity != 0:
			_direction += (position - origin_position).rotated(PI/2)*data.angular_velocity
		if data.shot_speed == 0:
			_direction += origin_velocity
		if _traveled_distance < 200:
			rotation = (position - origin_position).angle()
	position += _direction * delta
	_traveled_distance += data.shot_speed*delta
	
	if _traveled_distance > data.bullet_range:
		queue_free()

func _on_self_destruct_timeout():
	queue_free()

func _on_area_entered(area):
	if piercing_cooldown == 0:
		area.owner.hurt(self)
		if spawned_bullet:
			if origin_ref.get_ref() == GameState.player:
				fire_bullet.emit(self, spawned_bullet, "player")
			else:
				fire_bullet.emit(self, spawned_bullet, "enemy")
		if data.piercing == 0 or piercing == 0:
			queue_free()
		else:
			piercing -= 1
			piercing_cooldown = 10000
