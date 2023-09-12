extends CharacterBody2D

signal fire_bullet(bullet: BulletResource)
signal spawn

var resource: EnemyResource
@onready var sprite = $AnimatedSprite2D
@onready var health: int = resource.MAX_HP
@onready var damage: int = resource.DAMAGE
@onready var value: int = resource.VALUE
@onready var speed: int = resource.SPEED
@onready var bullet: BulletResource = resource.BULLET
@onready var unique_scale: Vector2
@onready var flipped: bool = resource.FLIP_H
@onready var floating: bool = resource.FLOATING
@onready var default_angle: float = self.rotation
@onready var default_scale: Vector2 = resource.SCALE

var _fire_timer: int = 0
var spawn_time: float


func _ready():
	name = resource.NAME
	scale = resource.SCALE
	default_scale = get_scale()
	sprite.sprite_frames = resource.ANIMATION
	sprite.flip_h = flipped
	$CollisionShape2D.shape = resource.COLLIDER
	$CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION

	# Select mob texture variants (This code is functional just unnecessary since no enemies have variants)
	var variants = sprite.sprite_frames.get_animation_names()
	var mode = variants[randi() % variants.size()]
	sprite.frame_progress = randf()
	sprite.play(mode)
	
	add_to_group("enemy")
	sway()

# Function for easing sprites between two positions while 'idle'. I.e. enemy rotation.
func sway():
	var tween: Tween = create_tween()
	var variance = 1/default_scale.length()
	if floating:
		tween.tween_property(sprite, "position", sprite.position + Vector2(0, 2*variance), 0.4) \
				.set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "position", sprite.position - Vector2(0, 2*variance), 0.4) \
				.set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)
	else:
		tween.tween_property(self, "rotation", default_angle + 0.03*variance, 0.4) \
				.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "rotation", default_angle - 0.03*variance, 0.4) \
				.set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)

# Move the enemy towards the player, handle deletion on death and fire bullets
# if the fire_delay has elapsed.
func _physics_process(_delta):
	var player_direction: Vector2 = (GameState.player.position - position)
	if player_direction.x < 0:
		sprite.flip_h = (true != flipped)
	else:
		sprite.flip_h = (false != flipped)
	velocity = player_direction.normalized() * speed
	move_and_slide()
	
	if health <= 0:
		queue_free()
		GameState.player.on_enemy_killed(value)
	
	# The enemy doesn't know what type of bullet it's firing.
	# We emit a fire_bullet event, which the main script handles.
	if bullet != null:
		if player_direction.length() > 500:
			_fire_timer = 0
		else:
			_fire_timer += 1
			if _fire_timer > bullet.fire_delay:
				_fire_timer -= bullet.fire_delay
				fire_bullet.emit(self, bullet)
	
	for area in $Hitbox.get_overlapping_areas():
		hit(area)

# Called by _on_hurtbox_area_entered - will only be called if the Area2D is in the bullet group
# Change the enemies health and tween to shrink the enemy briefly.
func hurt(area):
	health -= area.damage
	scale = default_scale * 0.65 
	var tween := create_tween()
	tween.tween_property(self, "global_scale", default_scale, 0.05)


func create_timer():
	var timer:= Timer.new()
	add_child(timer)
	timer.wait_time = spawn_time
	timer.one_shot = true

# Called when the enemy encounters something that hurts it.
func hit(area):
	if area.owner == GameState.player:
		area.owner.hurt(self)
