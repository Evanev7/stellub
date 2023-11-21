extends CharacterBody2D
class_name EnemyBehaviour

signal enemy_killed(enemy)
signal spawn_shop(pos)

@export var resource: EnemyResource
@export var damage_scene: PackedScene

@onready var unique_multiplier: float = resource.UNIQUE_MULTIPLIER
@onready var overall_multiplier: float = resource.OVERALL_MULTIPLIER

@onready var attack_handler: AttackHandler = $AttackHandler
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var damage_sound = $DamageSound
@onready var death_sound = $DeathSound
@onready var health: float = resource.MAX_HP * unique_multiplier * overall_multiplier
@onready var damage: float = resource.DAMAGE * unique_multiplier * overall_multiplier
@onready var value: float = resource.VALUE * unique_multiplier * overall_multiplier
@onready var strength: float = resource.STRENGTH * (0.5 + ((unique_multiplier  * overall_multiplier) / 2))
@onready var speed: float = resource.SPEED / (0.9 + (unique_multiplier / 10))
@onready var flipped: bool = resource.FLIP_H
@onready var floating: bool = resource.FLOATING
@onready var default_angle: float = self.rotation
@onready var default_scale: Vector2 = resource.SCALE * (0.5 + (unique_multiplier / 2))
@onready var variance = 1/default_scale.length()

var fire_on_hit: bool = false

@onready var damage_number_location = $Damage
@onready var damage_numbers = $DamageNumbers

var damage_scene_pool: Array[DamageNumber] = []
var movement_enabled: bool = true
var enemy_limit = 125
var dead: bool = false

func _ready():
	GameState.num_enemies += 1
	if owner:
		await(owner.ready)
	load_resource(resource)
	
	# Select mob texture variants (This code is functional just unnecessary since no enemies have variants)
	var variants = sprite.sprite_frames.get_animation_names()
	var mode = variants[randi() % variants.size()]
	sprite.frame_progress = randf()
	sprite.play(mode)
	
	
	add_to_group("enemy")
	sway()
	
	if get_index() >= enemy_limit:
		movement_enabled = false

func load_resource(resource_to_load: EnemyResource):
	name = resource_to_load.NAME
	scale = default_scale
	sprite.sprite_frames = resource_to_load.ANIMATION
	sprite.flip_h = flipped
	if unique_multiplier > 1:
		sprite.material.set_shader_parameter("line_color", Vector4(1, 0, 0, 1))
		sprite.material.set_shader_parameter("line_thickness", (unique_multiplier * 2) ** 2)
		
	if resource_to_load.BULLET:
		if resource_to_load.BULLET.target_mode == BulletResource.TARGET_MODE.MOUSE:
			resource_to_load.BULLET.target_mode = BulletResource.TARGET_MODE.PLAYER
		attack_handler.add_attack_from_resource(resource_to_load.BULLET)
		attack_handler.passive_all_attacks()
		if resource_to_load.BULLET.fire_on_hit:
			fire_on_hit = true
		
	$CollisionShape2D.shape = resource_to_load.COLLIDER
	$CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION
	$Hitbox/CollisionShape2D.shape = resource_to_load.HITBOX
	$Hitbox/CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION
	$Hurtbox/CollisionShape2D.shape = resource_to_load.HURTBOX
	$Hurtbox/CollisionShape2D.rotation = resource_to_load.COLLISION_ROTATION


# Function for easing sprites between two positions while 'idle'. I.e. enemy rotation.
func sway():
	var tween: Tween = create_tween()
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
	var player_direction = (GameState.player.position - position)
	if player_direction.x < 0:
		sprite.flip_h = (true != flipped)
	else:
		sprite.flip_h = (false != flipped)
	velocity = player_direction.normalized() * speed
	
	if get_index() < enemy_limit:
		movement_enabled = true
		
	if movement_enabled:
		move_and_slide()
	
	for area in hitbox.get_overlapping_areas():
		hit(area)

func change_colour():
	$AnimatedSprite2D.flip_v = true
	
# Called by _on_hurtbox_area_entered - will only be called if the Area2D is in the bullet group
# Change the enemies health and tween to shrink the enemy briefly.
func hurt(area):
	damage_sound.play()
	health -= area.damage
	scale = default_scale * 0.65 
	var tween2 := create_tween()
	tween2.tween_property(self, "global_scale", default_scale, 0.1)
	tween2.tween_property($AnimatedSprite2D, "self_modulate:v", 1, 0.05).from(50)
	
	if GameState.damage_numbers_enabled:
		spawn_damage_number(area.damage)
	
	if fire_on_hit:
		attack_handler.get_child(0).on_hit()
	
	
	#Die when health is zero
	if health <= 0 and not dead:
		dead = true
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		death_sound.play()
		enemy_killed.emit(self)
		set_process(false)
		visible = false
		
		if GameState.current_area == 1 and unique_multiplier > 1:
			spawn_shop.emit(global_position)
	
func _on_death_sound_finished():
	GameState.num_enemies -= 1
	queue_free()
	
	
func spawn_damage_number(damage_value: float):
	var damage_number = get_damage_number()
	if not damage_number:
		return
	var val = damage_value
	var pos = damage_number_location.position
	damage_numbers.add_child(damage_number, true)
	damage_number.set_values_and_animate(val, pos, damage_numbers.get_child_count() * 5, 100 + 5 * damage_numbers.get_child_count())

func get_damage_number() -> DamageNumber:
	if damage_scene_pool.size() > 0:
		return damage_scene_pool.pop_front()
	elif GameState.num_damage_labels < 1000:
		GameState.num_damage_labels += 1
		var new_damage_number = damage_scene.instantiate()
		new_damage_number.tree_exiting.connect(
			func():
				damage_scene_pool.append(new_damage_number))
		return new_damage_number
	else:
		return null

# Called when the enemy encounters something that it hurts.
func hit(area):
	if area.owner == GameState.player:
		area.owner.hurt(self)





