extends CharacterBody2D
class_name EnemyBehaviour

signal enemy_killed(enemy)

@export var resource: EnemyResource

@onready var attack_handler: AttackHandler = $AttackHandler
@onready var sprite = $AnimatedSprite2D
@onready var health: float = resource.MAX_HP
@onready var damage: float = resource.DAMAGE
@onready var value: float = resource.VALUE
@onready var speed: float = resource.SPEED
@onready var unique_scale: Vector2
@onready var flipped: bool = resource.FLIP_H
@onready var floating: bool = resource.FLOATING
@onready var default_angle: float = self.rotation
@onready var default_scale: Vector2 = resource.SCALE


var spawn_time: float


func _ready():
	load_resource(resource)
	
	# Select mob texture variants (This code is functional just unnecessary since no enemies have variants)
	var variants = sprite.sprite_frames.get_animation_names()
	var mode = variants[randi() % variants.size()]
	sprite.frame_progress = randf()
	sprite.play(mode)
	
	add_to_group("enemy")
	sway()

func load_resource(resource_to_load: EnemyResource):
	name = resource_to_load.NAME
	scale = resource_to_load.SCALE
	sprite.sprite_frames = resource_to_load.ANIMATION
	sprite.flip_h = flipped
	if resource_to_load.BULLET:
		attack_handler.add_attack_from_resource(resource_to_load.BULLET)
	$CollisionShape2D.shape = resource_to_load.COLLIDER
	$CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource_to_load.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource_to_load.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION


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
	
	#Die when health is zero
	if health <= 0:
		enemy_killed.emit(self)
		queue_free()
	
	for area in $Hitbox.get_overlapping_areas():
		hit(area)


# Called by _on_hurtbox_area_entered - will only be called if the Area2D is in the bullet group
# Change the enemies health and tween to shrink the enemy briefly.
func hurt(area):
	health -= area.damage
	scale = default_scale * 0.65 
	var tween := create_tween()
	tween.tween_property(self, "global_scale", default_scale, 0.1)


# Called when the enemy encounters something that it hurts.
func hit(area):
	if area.owner == GameState.player:
		area.owner.hurt(self)


