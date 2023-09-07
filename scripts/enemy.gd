extends CharacterBody2D

#@export var SPEED: int = 100
#@export var MAX_HP: int = 10
#@export var DAMAGE: int = 1
#@export var VALUE: int = 1

@onready var sprite = $AnimatedSprite2D
@onready var health : int
@onready var damage : int
@onready var value : int
@onready var speed : int
@onready var flipped : bool
@onready var resource : enemyResource

var animation_delay
var mode

func _ready():
	health = resource.MAX_HP
	damage = resource.DAMAGE
	value = resource.VALUE
	speed = resource.SPEED
	flipped = resource.FLIP_H
	sprite.sprite_frames = resource.ANIMATION
	sprite.flip_h = flipped
	$CollisionShape2D.shape = resource.COLLIDER
	$CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION
	
	# Select mob texture variants for later
	var variants = sprite.sprite_frames.get_animation_names()
	mode = variants[randi() % variants.size()]
	animation_delay = randi_range(0,20)
	
	add_to_group("enemy")


func _physics_process(delta):
	var direction = (GameState.player.position - position).normalized()
	if direction.x < 0:
		sprite.flip_h = (true != flipped)
	else:
		sprite.flip_h = (false != flipped)
	velocity = direction * speed
	move_and_slide()

	if health <= 0:
		queue_free()
		GameState.player.hit(value)

	if animation_delay < 0:
		pass
	elif animation_delay > 0:
		animation_delay -= 1
	elif animation_delay == 0:
		sprite.play(mode)
		animation_delay -= 1
	
	if $Hurtbox.overlaps_body(GameState.player):
		GameState.player.hurt(self)


func hurt(bullet):
	health -= bullet.damage
	bullet.queue_free()
	scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(self, "global_scale", Vector2(0.6, 0.6), 0.02)



func _on_hurtbox_area_entered(area: Area2D):
	if area.is_in_group("bullet"):
		hurt(area)
