extends CharacterBody2D

@export var SPEED: int = 100
@export var MAX_HP: int = 10
@export var DAMAGE: int = 1

var health
var damage
var animation_delay
var mode

func _ready():
	# Select mob texture variants for later
	var variants = $AnimatedSprite2D.sprite_frames.get_animation_names()
	mode = variants[randi() % variants.size()] 
	animation_delay = randi_range(0,60)
	
	add_to_group("enemy")
	health = MAX_HP
	damage = DAMAGE
	
func _physics_process(delta):
	var direction = (GameState.player.position - position).normalized()
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	velocity = direction * SPEED
	move_and_slide()
		
	if health <= 0:
		queue_free()
	if animation_delay < 0:
		pass
	elif animation_delay > 0:
		animation_delay -= 1
	elif animation_delay == 0:
		$AnimatedSprite2D.play(mode)
		animation_delay -= 1
		
	
	if $Hurtbox.overlaps_body(GameState.player):
		GameState.player.hit(self)

func hit(bullet):
	health -= bullet.damage
	scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(self, "global_scale", Vector2(0.6, 0.6), 0.02)

