extends Area2D


var data: BulletResource
@onready var spawned_bullet: BulletResource = data.spawned_bullet_resource

var piercing_cooldown: float = 0
var direction: Vector2 = Vector2(0,0)
var origin_ref: WeakRef


@onready var sprite = $AnimatedSprite2D
@onready var _traveled_distance: float = data.start_range
@onready var shot_speed: float = data.shot_speed
@onready var piercing: int = data.piercing
@onready var damage: float = data.damage
@onready var origin_position: Vector2

var _hit_targets: Array


# Called when the node enters the scene tree for the first time.
# Set some initial rotations, and set different collision layer for player and
# enemy bullets.
func _ready():
	add_to_group("bullet")
	var origin: Node2D = origin_ref.get_ref()
	if origin == GameState.player:
		set_collision_mask(4)
		$Vacuum.set_collision_mask(4)
	scale = data.size
	sprite.sprite_frames = data.animation
	$SelfDestruct.wait_time = data.lifetime
	$SelfDestruct.start()
	rotation = direction.angle()
	$AnimatedSprite2D.modulate = data.colour
	$AnimatedSprite2D.play()
	
	if data.vacuum:
		$BackBufferCopy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
		$Shader.process_mode = Node.PROCESS_MODE_INHERIT
		$Shader.visible = true
		$Vacuum/CollisionShape2D.disabled = false
		$Vacuum/CollisionShape2D.shape.radius = data.vacuum_range
	
	if data.activation_delay > 0:
		$CollisionShape2D.disabled = true
		$Vacuum/CollisionShape2D.disabled = true
		await get_tree().create_timer(data.activation_delay).timeout
		
		$CollisionShape2D.disabled = false
		if data.vacuum:
			$Vacuum/CollisionShape2D.disabled = false
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	transport(delta)
	shot_speed = max(shot_speed + delta * data.shot_acceleration,0)
	
	if _traveled_distance > data.bullet_range:
		if data.spawn_on_timeout and spawned_bullet:
			spawn_child()
		queue_free()
	
	if piercing_cooldown > 0:
		piercing_cooldown -= 1.0
	#If a bullet is able to hit the same enemy multiple times.
	elif piercing_cooldown <= 0 and data.piercing_cooldown != 0:
		for area in get_overlapping_areas():
			successful_hit(area.owner)
		piercing_cooldown = data.piercing_cooldown
	
	if data.vacuum:
		for area in $Vacuum.get_overlapping_areas():
			if area.owner.has_method("hurt"):
				var enemy = area.owner
				enemy.position += (position - enemy.position).normalized()* (data.vacuum_strength / enemy.strength)


func transport(delta) -> void:
	var _direction = direction * shot_speed
	match data.transport_mode:
		BulletResource.TRANSPORT_MODE.LINEAR:
			assert(data.angular_velocity == 0, "Transport mode should not be linear")
			position += direction * shot_speed * delta
			_traveled_distance += shot_speed * delta
		
		BulletResource.TRANSPORT_MODE.ROTATING_FIXED_CENTRE:
			var origin = origin_ref.get_ref()
			if not origin:
				queue_free()
				return
			rotation += data.angular_velocity * delta
			position = origin.position + (Vector2.UP*data.start_range).rotated(rotation+PI/2)
			_traveled_distance += data.start_range * data.angular_velocity * delta
		
		BulletResource.TRANSPORT_MODE.ROTATING_LINEAR_CENTRE:
			assert(false, "Not yet implemented")
		
		BulletResource.TRANSPORT_MODE.ROTATING_NO_CENTRE:
			var origin = origin_ref.get_ref()
			if origin:
				origin_position = origin.position
			var offset: Vector2 = (position - origin_position)
			_direction += offset.rotated(PI/2) * data.angular_velocity
			position += _direction * delta
			rotation = _direction.angle()
			_traveled_distance += shot_speed * delta
		
		BulletResource.TRANSPORT_MODE.STATIC:
			pass


func _on_self_destruct_timeout():
	if data.spawn_on_timeout and spawned_bullet:
		spawn_child()
	queue_free()


func _on_area_entered(area):
	var area_owner = area.owner
	if area_owner not in _hit_targets:
		#First hit on a new enemy should always count.
		successful_hit(area_owner)
		piercing_cooldown = data.piercing_cooldown


func successful_hit(target):
	if target and target not in _hit_targets:
		_hit_targets.append(target)
		
	#Damage target
	if target.has_method("hurt"):
		if target is EnemyBehaviour:
			target.position -= target.velocity * data.knockback / (10 * target.resource.STRENGTH)
		target.hurt(self)
	
	if spawned_bullet:
		spawn_child()
	
	#Handle bullet destruction.
	piercing -= 1
	if piercing == 0:
		queue_free()

func spawn_child() -> void:
	#Spawn child bullets, currently continuing in the bullets direction.
	var fire_from = FireFrom.new()
	fire_from.position = position
	fire_from.direction = direction
	GameState.fire_bullet.emit(origin_ref, spawned_bullet, fire_from)
