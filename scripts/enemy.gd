extends CharacterBody2D

signal fire_bullet(bullet: BulletResource)

@onready var sprite = $AnimatedSprite2D
@onready var health : int
@onready var damage : int
@onready var value : int
@onready var speed : int
@onready var unique_scale : Vector2
@onready var flipped : bool
@onready var resource : EnemyResource

var animation_delay
var default_scale
var mode
var default_angle
var floating
var fire_delay
var _fire_timer: int = 0
var bullet

func _ready():
	# we shouldn't need any of these, the resource can be more than a list of default constants
	name = resource.NAME
	health = resource.MAX_HP
	damage = resource.DAMAGE
	value = resource.VALUE
	speed = resource.SPEED
	flipped = resource.FLIP_H
	floating = resource.FLOATING
	bullet = resource.BULLET
	
	# these are fine
	sprite.sprite_frames = resource.ANIMATION
	sprite.flip_h = flipped
	default_angle = self.rotation_degrees
	scale = resource.SCALE
	default_scale = get_scale()
	$CollisionShape2D.shape = resource.COLLIDER
	$CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource.COLLISION_ROTATION

	
	# Select mob texture variants for later (This code is functional just unnecessary)
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
	var player_direction: Vector2 = (GameState.player.position - position)
	if player_direction.x < 0:
		sprite.flip_h = (true != flipped)
	else:
		sprite.flip_h = (false != flipped)
	velocity = player_direction.normalized() * speed
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
	
	if bullet != null:
		if player_direction.length() > 500:
			_fire_timer = 0
		else:
			_fire_timer += 1
			if _fire_timer > bullet.fire_delay:
				_fire_timer -= bullet.fire_delay
				fire_bullet.emit(self, bullet)

func hurt(area):
	health -= area.data.damage
	area.queue_free()
	scale = default_scale * 0.65 
	var tween := create_tween()
	tween.tween_property(self, "global_scale", default_scale, 0.05)


func _on_hurtbox_area_entered(area: Area2D):
	if area.is_in_group("bullet") and area.origin == GameState.player:
		hurt(area)
