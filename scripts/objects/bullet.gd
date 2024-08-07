extends Area2D
class_name Bullet

signal on_remove()

var dead: bool
var data: BulletResource
var spawned_bullet: BulletResource

var piercing_cooldown: float = 0
var direction: Vector2 = Vector2(0,0)
var origin_ref: WeakRef


var sprite: AnimatedSprite2D
var _traveled_distance: float
var _cur_range: float
var _angle: float
var shot_speed: float
var shot_speed_negative: bool
var piercing: int
var damage: float
@onready var origin_position: Vector2
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var self_destruct = $SelfDestruct

var _hit_targets: Array
@export var vacuum_scene: PackedScene
var has_vacuum = false
var vacuum

# Called when the node enters the scene tree for the first time.
# Set some initial rotations, and set different collision layer for player and
# enemy bullets.
func _ready():
	dead = true
	collision.disabled = true
	set_physics_process(false)
	hide()

	
func set_data():
	spawned_bullet = data.spawned_bullet_resource
	sprite = $AnimatedSprite2D
	_cur_range = 0
	_traveled_distance = data.start_range
	shot_speed = data.shot_speed
	shot_speed_negative = data.can_be_negative
	piercing = data.piercing
	damage = data.damage
	var origin: Node2D = origin_ref.get_ref()
	if data.vacuum and has_vacuum == false:
		has_vacuum = true
		vacuum = vacuum_scene.instantiate()
		call_deferred("add_child", vacuum)
		if origin == GameState.player:
			vacuum.set_collision_mask(4)
	
	if origin == GameState.player:
		set_collision_mask(4)
	else:
		set_collision_mask(2)
	scale = data.size
	sprite.sprite_frames = data.animation
	self_destruct.wait_time = data.lifetime
	self_destruct.start()
	
	match data.facing_direction:
		BulletResource.FACING_DIRECTION.DEFAULT:
			rotation = direction.angle()
		BulletResource.FACING_DIRECTION.UP:
			rotation = Vector2(0, -1).angle()
		BulletResource.FACING_DIRECTION.DOWN:
			rotation = Vector2(0, 1).angle()
		BulletResource.FACING_DIRECTION.LEFT:
			rotation = Vector2(1, 0).angle()
		BulletResource.FACING_DIRECTION.RIGHT:
			rotation = Vector2(-1, 0).angle()
	_angle = rotation
			
	$AnimatedSprite2D.modulate = data.colour
	$AnimatedSprite2D.play()
	
	if data.vacuum:
		$BackBufferCopy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
		$Shader.process_mode = Node.PROCESS_MODE_INHERIT
		$Shader.visible = true
		vacuum.get_node("CollisionShape2D").shape.radius = data.vacuum_range
	
	if data.activation_delay > 0:
		collision.set_deferred("disabled", true)
		if data.vacuum:
			vacuum.get_node("CollisionShape2D").disabled = true
		await get_tree().create_timer(data.activation_delay).timeout
		
		collision.disabled = false
		if data.vacuum:
			vacuum.get_node("CollisionShape2D").disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	transport(delta)
	if shot_speed_negative:
		shot_speed += delta * data.shot_acceleration
	else:
		shot_speed = max(shot_speed + delta * data.shot_acceleration,0)
	
	if _traveled_distance > data.bullet_range:
		if data.spawn_on_timeout and spawned_bullet:
			spawn_child()
		remove()
	
	if piercing_cooldown > 0:
		piercing_cooldown -= 1.0
	#If a bullet is able to hit the same enemy multiple times.
	elif piercing_cooldown <= 0 and data.piercing_cooldown != 0:
		for area in get_overlapping_areas():
			if not dead:
				successful_hit(area.owner)
		piercing_cooldown = data.piercing_cooldown
	
	if vacuum:
		for area in vacuum.get_overlapping_areas():
			if area.owner.has_method("hurt"):
				var enemy = area.owner
				enemy.position += (position - enemy.position).normalized()* (data.vacuum_strength / enemy.strength)


func transport(delta) -> void:
	var _direction = direction * shot_speed
	match data.transport_mode:
		BulletResource.TRANSPORT_MODE.LINEAR:
			assert(data.angular_velocity == 0, "Transport mode should not be linear")
			position += direction * shot_speed * delta
			_traveled_distance += abs(shot_speed) * delta
		
		BulletResource.TRANSPORT_MODE.ROTATING_FIXED_CENTRE:
			var origin = origin_ref.get_ref()
			if not origin:
				remove()
				return
			_cur_range = clamp(_cur_range + 500 * delta,0, data.start_range)
			_angle += data.angular_velocity * delta
			position = origin.position + (Vector2.RIGHT*_cur_range).rotated(_angle)
			rotation = _angle + TAU/4 * (_cur_range/data.start_range)
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
			_traveled_distance += abs(shot_speed) * delta
		
		BulletResource.TRANSPORT_MODE.STATIC:
			rotation += data.angular_velocity
			pass
			
func _on_self_destruct_timeout():
	if data.spawn_on_timeout and spawned_bullet:
		spawn_child()
	remove()


func _on_area_entered(area):
	var area_owner = area.owner
	if area_owner not in _hit_targets and not dead:
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
		remove()

func spawn_child() -> void:
	#Spawn child bullets, currently continuing in the bullets direction.
	var fire_from = FireFrom.new()
	fire_from.position = position
	fire_from.direction = direction
	GameState.fire_bullet.emit(origin_ref, spawned_bullet, fire_from)

func remove() -> void:
	GameState.num_bullets -= 1
	on_remove.emit()
	dead = true
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	hide()
	remove_from_group("bullet")
	_traveled_distance = 0
	_hit_targets.clear()
