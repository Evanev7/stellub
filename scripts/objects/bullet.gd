extends Area2D

@onready var data: BulletResource
@onready var spawned_bullet: BulletResource = data.spawned_bullet_resource
@onready var sprite = $AnimatedSprite2D
@onready var _traveled_distance: float = data.start_range

var piercing
var piercing_cooldown = 0
var direction: Vector2 = Vector2(0,0)
var origin_ref: WeakRef
var relative_position
var origin_position
var origin_velocity

var damage
var _hit_targets: Array


# Called when the node enters the scene tree for the first time.
# Set some initial rotations, and set different collision layer for player and
# enemy bullets.
func _ready():
	add_to_group("bullet")
	if origin_ref.get_ref() == GameState.player:
		set_collision_mask(4)
	scale = data.size
	piercing = data.piercing
	damage = data.damage
	sprite.sprite_frames = data.animation
	$SelfDestruct.wait_time = data.lifetime
	$SelfDestruct.start()
	rotation = direction.angle()
	var origin = origin_ref.get_ref()
	origin_position = origin.position
	origin_velocity = origin.velocity
	$AnimatedSprite2D.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	transport(delta)
	
	if _traveled_distance > data.bullet_range:
		queue_free()
	
	
	if piercing_cooldown > 0:
		piercing_cooldown -= 1
	#If a bullet is able to hit the same enemy multiple times.
	elif piercing_cooldown == 0 and data.piercing_cooldown != 0:
		for area in get_overlapping_areas():
			successful_hit(area.owner)
		piercing_cooldown = data.piercing_cooldown


func transport(delta):
	var _direction = direction * data.shot_speed
	var origin = origin_ref.get_ref()
	if origin:
		origin_position = origin.position
		origin_velocity = origin.velocity
	if data.angular_velocity != 0:
		_direction += (position - origin_position).rotated(PI/2)*data.angular_velocity
		rotation = _direction.angle()
	if data.shot_speed == 0:
		_direction += origin_velocity
		rotation = (position - origin_position).angle()
	position += _direction * delta
	_traveled_distance += data.shot_speed*delta


func _on_self_destruct_timeout():
	queue_free()


func _on_area_entered(area):
	var area_owner = area.owner
	if area_owner not in _hit_targets:
		print(area_owner.name, " aka ", area, " aka ", area.owner)
		
		#First hit on a new enemy should always count.
		successful_hit(area_owner)
		piercing_cooldown = data.piercing_cooldown


func successful_hit(target):
	if target:
		_hit_targets.append(target)
		
	#Damage target
	if target.has_method("hurt"):
		target.hurt(self)
	
	#Spawn child bullets, currently aimed toward the player.
	if spawned_bullet:
			var fire_from = FireFrom.new()
			fire_from.toward(position, GameState.player.position)
			if origin_ref.get_ref() == GameState.player:
				fire_from.direction *= -1
			GameState.fire_bullet.emit(origin_ref, spawned_bullet, fire_from)
	
	#Handle bullet destruction.
	piercing -= 1
	if piercing == 0:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("terrain"):
		queue_free()
