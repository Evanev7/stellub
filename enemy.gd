extends CharacterBody2D

@export var SPEED: int = 100
@export var MAX_HP: int = 10
var health

func _ready():	
	# Select mob texture variants for later
	var variants = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(variants[randi() % variants.size()]) 
	add_to_group("enemy")
	health = MAX_HP
	
func _physics_process(delta):
	var direction = (GameState.player.position - position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body == GameState.player:
			GameState.player.hit(self)
		
	if health <= 0:
		queue_free()

func hit(bullet):
	health -= bullet.damage
	scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(self, "global_scale", Vector2(0.6, 0.6), 0.02)
