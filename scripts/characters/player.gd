extends CharacterBody2D

signal hp_changed(hp)
signal player_death
signal level_up(level)
signal credit_player(value)
signal show_freeze(time)

## Player Stats
@export var STARTING_SPEED: float = 300.0
@export var STARTING_HP_MAX: float = 100
@export var STARTING_WEAPON: BulletResource

@export var stat_upgrade: UpgradeResource
@export var attack_handler: Node2D

@onready var default_scale: Vector2 = self.scale
@onready var default_pickup_range: Vector2 = $PickupRange.scale
@onready var pickup_range: Area2D = $PickupRange
@onready var strength: float = 5
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var i_frame_timer: Timer = $IFrames
@onready var blood_particles: GPUParticles2D = $Blood

@onready var pickup_sound: AudioStreamPlayer = $Pickup
@onready var hp_pickup_sound: AudioStreamPlayer = $HPPickup
@onready var vacuum_pickup_sound: AudioStreamPlayer = $VacuumPickup
@onready var freeze_pickup_sound: AudioStreamPlayer = $FreezePickup
@onready var level_up_sound: AudioStreamPlayer = $LevelUp
@onready var hurt_sound: AudioStreamPlayer = $Hurt
@onready var death_sound: AudioStreamPlayer = $Die
@onready var camera_2d = $Camera2D

var control_mode: int = 0
var level_threshold = [10, 20, 30, 50]
var current_level: int

var current_evolution: int

var hp_max: float
var speed: float:
	set(value):
		speed = clamp(value, 100, 600)
var hp:  float
var score: float
var walking: bool = false


var invuln: bool = false
var dead: bool = false
var current_animation: String

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	hide()
	attack_handler.stop()
	set_physics_process(false)

func _input(event):
	if event is InputEventMouseMotion:
		camera_2d.offset = (event.position - get_viewport_rect().size/2)/32

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if GameState.player_data.gamepad_enabled:
		var direction: Vector2
		var movement: Vector2
		direction.x = Input.get_action_strength("move_cursor_right") - Input.get_action_strength("move_cursor_left")
		direction.y = Input.get_action_strength("move_cursor_down") - Input.get_action_strength("move_cursor_up")
		
		if abs(direction.x) == 1 and abs(direction.y) == 1:
			direction = direction.normalized()

		movement = 800.0 * direction * _delta
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + movement)
	
	
	velocity = Input.get_vector("move_left", "move_right","move_up", "move_down")
	
	# Handle user input
	if Input.is_action_just_pressed("walk"):
		walking = true
	if Input.is_action_just_released("walk"):
		walking = false
	
	if velocity.length() > 0:
		if walking:
			velocity = velocity.normalized() * speed/2
		else:
			velocity = velocity.normalized() * speed
		
		# Flip the player sprite depending on the direction we're facing
		if velocity.x < 0 and not sprite.flip_h:
			sprite.flip_h = true
		elif velocity.x > 0 and sprite.flip_h:
			sprite.flip_h = false
		
		move_and_slide()
		
		# Walk animation
		sprite.play(current_animation)
	else:
		sprite.play(current_animation)

	if invuln:
		blood_particles.emitting = true
	else:
		blood_particles.emitting = false
		
	var screen_coords = get_viewport_transform() * global_position
	var normalized_screen_coords = screen_coords / Vector2(DisplayServer.screen_get_size())
	RenderingServer.global_shader_parameter_set("player_position", normalized_screen_coords)

# When the game starts, set the default values and show the player.
func start():
	set_default_stats()
	enable()

func enable():
	show()
	set_physics_process(true)
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	attack_handler.start()

# Set default player stats
func set_default_stats():
	## Player Stats
	speed = STARTING_SPEED
	hp_max = STARTING_HP_MAX
	hp = hp_max
	invuln = false
	dead = false
	score = 0
	current_level = 0
	current_animation = "level 0"
	current_evolution = 0
	scale = default_scale
	pickup_range.scale = default_pickup_range
	rotation = 0
	
	GameState.reset_statistics()
	
	## Weapon Stats
	for attack in attack_handler.get_children():
		attack.queue_free()
	# If starting weapon is normal bullet
	STARTING_WEAPON.target_mode = BulletResource.TARGET_MODE.MOUSE
	attack_handler.add_attack_from_resource(STARTING_WEAPON)

func add_attack_from_resource(bullet: BulletResource):
	var modes = Attack.CONTROL_MODE
	var available_modes = [modes.PRIMARY, modes.SECONDARY, modes.TERTIARY, modes.PASSIVE]
	attack_handler.add_attack_from_resource(bullet, available_modes[control_mode])
	control_mode = clamp(control_mode + 1, 0, 3)

# Called when the player gets hurt. Body can be either a bullet OR an enemy.
func hurt(body):
	if not invuln and not body.is_in_group("pickup"):
		hp = clamp(hp - body.damage, 0, hp_max)
		hp_changed.emit(hp, hp_max)
		hurt_sound.play()
		invuln = true
		i_frame_timer.start()
		sprite.modulate = Color(1,0,0,0.5)
		sprite.material.set_shader_parameter("line_color", Vector4(1, 0, 0, 1))
		sprite.material.set_shader_parameter("line_thickness", 5)
		sprite.material.set_shader_parameter("value", randf_range(0.4, 0.6))
		
	if hp <= 0 and not dead:
		dead = true
		GameState.player_data.total_deaths += 1
		attack_handler.stop()
		death_sound.play()
		if GameState.player_data.first_time == true:
			i_frame_timer.stop()
			_on_i_frames_timeout()
			invuln = true
		else:
			hide()
			$CollisionShape2D.set_deferred("disabled", true)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		set_physics_process(false)
		player_death.emit()



func activate_pickup(area):
	if area.is_in_group("pickup"):
		area.activate()

func get_pickup(area):
	if not area.is_in_group("pickup"):
		return
	if area.collected:
		return
	area.collected = true
	
	match area.pickup_type:
		Pickup.xp_pickup:
			credit_player.emit(area.value)
			pickup_sound.play()
		Pickup.hp_pickup:
			heal(area.value)
			hp_pickup_sound.play()
			GameState.player_data.total_pickups_collected += 1
		Pickup.vacuum_pickup:
			activate_xp_vacuum()
			vacuum_pickup_sound.play()
			GameState.player_data.total_pickups_collected += 1
		Pickup.freeze_pickup:
			freeze_pickup_sound.play()
			show_freeze.emit(float(area.value))
			GameState.player_data.total_pickups_collected += 1
		Pickup.fire_pickup:
			if attack_handler.get_node_or_null("Fire"):
				free_fire_upgrade(float(area.value), true)
			else:
				attack_handler.add_attack_from_resource(preload("res://resources/bullets/player/fire.tres"), Attack.CONTROL_MODE.PASSIVE)
				free_fire_upgrade(float(area.value))
			GameState.player_data.total_pickups_collected += 1
	area.queue_free()

# Called when we've killed an enemy, and we can add to our score.
func gain_score(value):
	score += value
	GameState.souls_collected += value
	GameState.player_data.total_souls_collected += value
	var tween: Tween = create_tween()
	sprite.material.set_shader_parameter("line_color", Vector4(1, 1, 1, 1))
	tween.tween_property(sprite.material, "shader_parameter/line_thickness", 0, 0.2).from(10.0)
	tween.tween_callback(func(): sprite.material.set_shader_parameter("line_color", Vector4(0, 0, 0, 0)))
	
	while score >= level_threshold[current_level]:
		level_up.emit(current_level)
		player_level_up()
		if level_threshold[current_level] > 10000:
			level_threshold.append(level_threshold[current_level] * 1.1)
		elif level_threshold[current_level] > 2000:
			level_threshold.append(level_threshold[current_level] + 500)
		elif level_threshold[current_level] > 1000:
			level_threshold.append(level_threshold[current_level] + 200)
		elif level_threshold[current_level] > 500:
			level_threshold.append(level_threshold[current_level] + 100)
		elif level_threshold[current_level] > 200:
			level_threshold.append(level_threshold[current_level] + 50)
		elif level_threshold[current_level] > 49:
			level_threshold.append(level_threshold[current_level] + 30) 

func heal(value):
	hp = clamp(hp + value, 0, hp_max)
	hp_changed.emit(hp, hp_max)
	
func activate_xp_vacuum():
	get_tree().call_group("xp_pickup", "activate")
	
func free_fire_upgrade(value, present: bool = false):
	if present:
		$FireTimer.wait_time = $FireTimer.time_left + value
		$FireTimer.start()
	else:
		$FireTimer.wait_time = value
		$FireTimer.start()

func _on_fire_timer_timeout():
	if attack_handler.get_node_or_null("Fire"):
		attack_handler.remove_child(attack_handler.get_node("Fire"))

func player_level_up():
	current_level += 1
	var old_hp_max = hp_max
	hp_max *= 1.05
	hp += hp_max - old_hp_max
	speed *= 1.005
	pickup_range.scale *= 1.03
	level_up_sound.play()
	
	attack_handler.upgrade_all_attacks(stat_upgrade)

func upgrade_attack(upgrade, weapon_number):
	print(upgrade)
	attack_handler.get_child(weapon_number).add_child(upgrade)
	attack_handler.get_child(weapon_number).refresh_bullet_resource()


func evolve(val = -1):
	if val == -1:
		current_evolution += 1
	else:
		current_evolution = max(val, current_evolution)
	current_animation = "level " + str(clamp(current_evolution, 0, 6))
	
	var scaling_factors = {
		0: 1.5,
		1: 1.1,
		2: 0.9,
		5: 1.1
	}
	
	var total_scale := default_scale
	for i in range(current_evolution):
		if i in scaling_factors.keys():
			total_scale *= scaling_factors[i]
		else:
			total_scale *= 1.08
	scale = total_scale


func _on_i_frames_timeout():
	sprite.modulate = Color(1,1,1,1)
	sprite.material.set_shader_parameter("line_color", Vector4(1, 1, 1, 0))
	sprite.material.set_shader_parameter("line_thickness", 0)
	sprite.material.set_shader_parameter("value", 1)
	invuln = false


