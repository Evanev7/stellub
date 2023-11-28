extends CharacterBody2D
class_name EnemyBehaviour

signal enemy_killed(enemy)
signal on_remove()
signal spawn_shop(pos)
signal play_damage_sound(pos)
signal play_death_sound(pos)
signal spawn_damage_number(damage_value: float, position: Vector2, size: Vector2)

@export var resource: EnemyResource
@export var damage_scene: PackedScene
@export var teleport_back_to_player_range: int = 2000

@onready var unique_multiplier: float
@onready var overall_multiplier: float

@onready var hitbox := $Hitbox
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collisionshape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox_collisionshape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var shadow: Sprite2D = $Shadow

@onready var attack_handler: AttackHandler = $AttackHandler
@onready var health: float
@onready var damage: float
@onready var value: float
@onready var strength: float
@onready var speed: float
@onready var flipped: bool
@onready var floating: bool
@onready var default_angle: float
@onready var default_scale: Vector2
@onready var variance: float
var dead: bool = false

var fire_on_hit: bool = false

@onready var damage_number_location = $Damage
@onready var damage_numbers = $DamageNumbers

static var damage_scene_pool: Array[DamageNumber] = []
var movement_enabled: bool = true
var enemy_limit = 200

var contact_areas: Array = []

func _ready():
	dead = true
	collider.set_deferred("disabled", true)
	hitbox_collisionshape.set_deferred("disabled", true)
	hurtbox_collisionshape.set_deferred("disabled", true)
	set_physics_process(false)
	sprite.visible = false
	shadow.visible = false

		
func set_data():
	unique_multiplier = resource.UNIQUE_MULTIPLIER
	overall_multiplier = resource.OVERALL_MULTIPLIER
	
	health  = resource.MAX_HP * unique_multiplier * overall_multiplier
	damage  = resource.DAMAGE * unique_multiplier * overall_multiplier
	value  = resource.VALUE * unique_multiplier * overall_multiplier
	strength  = resource.STRENGTH * (0.5 + ((unique_multiplier  * overall_multiplier) / 2))
	speed  = resource.SPEED / (0.9 + (unique_multiplier / 10))
	flipped = resource.FLIP_H
	floating = resource.FLOATING
	default_angle = self.rotation
	default_scale = resource.SCALE * (0.75 + (unique_multiplier / 4))
	variance = 1/default_scale.length()
	
	
	load_resource(resource)
	attack_handler.start()
	
	# Select mob texture variants (This code is functional just unnecessary since no enemies have variants)
	var variants = sprite.sprite_frames.get_animation_names()
	var mode = variants[randi() % variants.size()]
	sprite.frame_progress = randf()
	sprite.play(mode)
	
	add_to_group("enemy")
	#sway()
	
	if GameState.num_enemies >= enemy_limit:
		movement_enabled = false

func load_resource(resource_to_load: EnemyResource):
	name = resource_to_load.NAME
	scale = default_scale
	sprite.sprite_frames = resource_to_load.ANIMATION
	sprite.flip_h = flipped
	if unique_multiplier > 1:
		sprite.material.set_shader_parameter("line_color", Vector4(1, 0, 0, 1))
		sprite.material.set_shader_parameter("line_thickness", (unique_multiplier) ** 2)
		
	if resource_to_load.BULLET:
		if resource_to_load.BULLET.target_mode == BulletResource.TARGET_MODE.MOUSE:
			resource_to_load.BULLET.target_mode = BulletResource.TARGET_MODE.PLAYER
		attack_handler.add_attack_from_resource(resource_to_load.BULLET)
		attack_handler.passive_all_attacks()
		if resource_to_load.BULLET.fire_on_hit:
			fire_on_hit = true
		
	collider.shape = resource_to_load.COLLIDER
	collider.rotation = resource_to_load.COLLISION_ROTATION
	hitbox_collisionshape.shape = resource_to_load.HITBOX
	hitbox_collisionshape.rotation = resource_to_load.COLLISION_ROTATION
	hurtbox_collisionshape.shape = resource_to_load.HURTBOX
	hurtbox_collisionshape.rotation = resource_to_load.COLLISION_ROTATION
	
	shadow.position.y = (hitbox_collisionshape.shape.height / 2) - default_scale.length()


# Function for easing sprites between two positions while 'idle'. I.e. enemy rotation.
func sway():
	var tween: Tween = create_tween()
	if floating:
		sprite.position = Vector2(0, 0)
		tween.tween_property(sprite, "position", sprite.position + Vector2(0, 2*variance), 0.4) \
				.set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "position", sprite.position - Vector2(0, 2*variance), 0.4) \
				.set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)
	else:
		tween.tween_property(sprite, "rotation", default_angle + 0.03*variance, 0.4) \
				.set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "rotation", default_angle - 0.03*variance, 0.4) \
				.set_ease(Tween.EASE_OUT)
		tween.tween_callback(sway)

# Move the enemy towards the player, handle deletion on death and fire bullets
# if the fire_delay has elapsed.
func _physics_process(_delta):
	var player_direction = (GameState.player.position - position)
	
	if player_direction.length() > (teleport_back_to_player_range / (GameState.current_area + 1)):
		var relative_spawn_position = Vector2(800,0).rotated(randf_range(0, 2*PI))
		position = GameState.player.position + relative_spawn_position
	
	if player_direction.x < 0:
		sprite.flip_h = (true != flipped)
	else:
		sprite.flip_h = (false != flipped)
	velocity = player_direction.normalized() * speed
	
	if GameState.num_enemies < enemy_limit:
		movement_enabled = true
		
	if movement_enabled:
		move_and_slide()
	
	if contact_areas:
		for area in contact_areas:
			hit(area)

func change_colour():
	$AnimatedSprite2D.flip_v = true
	
# Called by _on_hurtbox_area_entered - will only be called if the Area2D is in the bullet group
# Change the enemies health and tween to shrink the enemy briefly.
func hurt(area):
	play_damage_sound.emit(global_position)
	health -= area.damage
	GameState.damage_dealt += area.damage
	scale = default_scale * 0.65 
	var tween2 := create_tween()
	tween2.tween_property(self, "global_scale", default_scale, 0.1)
	tween2.tween_property($AnimatedSprite2D, "self_modulate:v", 1, 0.05).from(50)
	
	if GameState.damage_numbers_enabled:
		spawn_damage_number.emit(area.damage, damage_number_location.global_position, default_scale)
	
	if fire_on_hit:
		attack_handler.get_child(0).on_hit()
	
	
	#Die when health is zero
	if health <= 0 and not dead:
		dead = true
		play_death_sound.emit(global_position)
		
		if GameState.current_area == 1 and unique_multiplier > 1:
			spawn_shop.emit(global_position)
			
		remove()
		enemy_killed.emit(self)
	
func remove():
	dead = true
	GameState.enemies_killed += 1
	GameState.num_enemies -= 1
	on_remove.emit()
	attack_handler.stop()
	collider.set_deferred("disabled", true)
	hitbox_collisionshape.set_deferred("disabled", true)
	hurtbox_collisionshape.set_deferred("disabled", true)
	set_physics_process(false)
	sprite.visible = false
	shadow.visible = false
	remove_from_group("enemy")


# Called when the enemy encounters something that it hurts.
func hit(area):
	if area.owner == GameState.player:
		area.owner.hurt(self)







func _on_hitbox_area_entered(area):
	contact_areas.append(area)


func _on_hitbox_area_exited(area):
	contact_areas.erase(area)
