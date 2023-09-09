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
@onready var resource : enemyResource
@onready var unique_scale : Vector2
@onready var flipped : bool

var animation_delay
var default_scale
var mode
var default_angle
var floating

func _ready():
	sprite.sprite_frames = resource.ANIMATION
	name = resource.NAME
	health = resource.MAX_HP
	damage = resource.DAMAGE
	value = resource.VALUE
	speed = resource.SPEED
	flipped = resource.FLIP_H
	sprite.sprite_frames = resource.ANIMATION
	sprite.flip_h = flipped
	default_angle = self.rotation_degrees
	scale = resource.SCALE
	default_scale = get_scale()
	floating = resource.FLOATING
	$CollisionShape2D.shape = resource.COLLIDER
	$CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION

	
	# Select mob texture variants for later
#	var variants = $AnimatedSprite2D.sprite_frames.get_animation_names()
#	mode = variants[randi() % variants.size()]
#	animation_delay = randi_range(0,20)
	
	add_to_group("enemy")
	sway()

func sway() -> void:
	var tween: Tween = create_tween()
	if floating:
		tween.tween_property(sprite, "position", Vector2(sprite.position.x, sprite.position.y + 2/default_scale.length()), 0.4).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "position", Vector2(sprite.position.x, sprite.position.y - 2/default_scale.length()), 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)
	else:
		tween.tween_property(self, "rotation_degrees", default_angle + 2/default_scale.length(), 0.4).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "rotation_degrees", default_angle - 2/default_scale.length(), 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)


func _physics_process(_delta):
	var direction = (GameState.player.position - position).normalized()
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	velocity = direction * speed
	move_and_slide()

	if health <= 0:
		queue_free()
		GameState.player.hit(value)

#	if animation_delay < 0:
#		pass
#	elif animation_delay > 0:
#		animation_delay -= 1
#	elif animation_delay == 0:
#		$AnimatedSprite2D.play(mode)
#		animation_delay -= 1
	
	if $Hurtbox.overlaps_body(GameState.player):
		GameState.player.hurt(self)


func hurt(bullet):
	health -= bullet.damage
	bullet.queue_free()
	scale = default_scale * 0.65 
	var tween := create_tween()
	tween.tween_property(self, "global_scale", default_scale, 0.05)



func _on_hurtbox_area_entered(area: Area2D):
	if area.is_in_group("bullet"):
		hurt(area)
