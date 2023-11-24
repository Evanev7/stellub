extends CharacterBody2D

signal hp_changed(hp)
signal player_death
signal level_up(level)
signal send_loadout(loadout)
signal player_ready
signal credit_player(value)

## Player Stats
@export var STARTING_SPEED: float = 300.0
@export var STARTING_HP_MAX: float = 100
@export var STARTING_WEAPON: BulletResource

@export var stat_upgrade: PackedScene
@export var attack_handler: Node2D

@onready var default_scale: Vector2 = self.scale
@onready var default_pickup_range: Vector2 = $PickupRange.scale
@onready var pickup_range: Area2D = $PickupRange
@onready var strength: float = 5
@onready var sprite: AnimatedSprite2D = $SubViewport/AnimatedSprite2D
@onready var i_frame_timer: Timer = $IFrames
@onready var blood_particles: GPUParticles2D = $Blood
@onready var pickup_sound: AudioStreamPlayer = $Pickup

var control_mode: int = 0
var level_threshold = [10, 20, 30, 50]
var current_level: int

var total_upgrades: int = 0
var current_evolution: int

var current_wave: int
var hp_max: float
var speed: float
var hp:  float
var score: float
var walking: bool = false


var invuln: bool = false
var dead: bool = false
var _h_flipped: bool = false
var current_animation: String


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.scale = Vector2(0.9, 0.9)
	GameState.player = self
	hide()
	attack_handler.stop()
	set_physics_process(false)
	player_ready.emit()

func _input(event):
	if event is InputEventMouseMotion:
		$Camera2D.offset = (event.position - get_viewport_rect().size/2)/32

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
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
		if velocity.x < 0 and not _h_flipped:
			scale = Vector2(-scale.x,scale.y)
			_h_flipped = true
		elif velocity.x > 0 and _h_flipped:
			scale = Vector2(-scale.x,scale.y)
			_h_flipped = false
		
		move_and_slide()
		var screen_coords = get_viewport_transform() * global_position
		var normalized_screen_coords = screen_coords / get_viewport().get_visible_rect().size
		RenderingServer.global_shader_parameter_set("player_position", normalized_screen_coords)
		
		# Walk animation
		sprite.play(current_animation)
	else:
		sprite.play(current_animation)

	if invuln:
		blood_particles.emitting = true
	else:
		blood_particles.emitting = false
		

# When the game starts, set the default values and show the player.
func start():
	current_wave = 1
	set_default_stats()
	show()
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$Hurtbox/CollisionShape2D.disabled = false
	$Camera2D.set_deferred("enabled", true)
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
	attack_handler.add_attack_from_resource(STARTING_WEAPON)
	total_upgrades = 0

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
		invuln = true
		i_frame_timer.start()
		sprite.modulate = Color(1,0,0,0.5)
		
	if hp <= 0 and not dead:
		dead = true
		attack_handler.stop()
		if GameState.first_time == true:
			i_frame_timer.stop()
			sprite.modulate = Color(1,1,1,1)
			invuln = true
		else:
			hide()
			$CollisionShape2D.disabled = true
			$Hurtbox/CollisionShape2D.disabled = true
			$Camera2D.set_deferred("enabled", false)
		set_physics_process(false)
		player_death.emit()


func activate_pickup(area):
	if area.is_in_group("pickup"):
		area.activate()

func get_pickup(area):
	## pickup_type constants: enum {xp_pickup, hp_pickup, vacuum_pickup}
	if area.is_in_group("pickup"):
		match area.pickup_type:
			Pickup.xp_pickup:
				credit_player.emit(area.value)
				pickup_sound.play()
			Pickup.hp_pickup:
				heal(area.value)
			Pickup.vacuum_pickup:
				activate_xp_vacuum()
		area.queue_free()

# Called when we've killed an enemy, and we can add to our score.
func gain_score(value):
	score += value
	GameState.souls_collected += value
	var tween: Tween = create_tween()
	if current_level < 2:
		tween.tween_property(sprite, "self_modulate:v", 1, 0.25).from(50)
	else:
		tween.tween_property(sprite, "self_modulate:v", 1, 0.25).from(5)
	
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

func player_level_up():
	var old_hp_max = hp_max
	hp_max *= 1.05
	hp += hp_max - old_hp_max
	speed *= 1.01
	pickup_range.scale *= 1.03
	current_level += 1
	
	attack_handler.upgrade_all_attacks(stat_upgrade)

func upgrade_attack(upgrade, weapon_number):
	attack_handler.get_child(weapon_number).add_child(upgrade)
	attack_handler.get_child(weapon_number).refresh_bullet_resource()
	
	total_upgrades += 1

#Marked for cleanup with new shop UI
func get_all_attacks():
	var attacks = []
	for attack in attack_handler.get_children():
		attacks.append(attack)
	return attacks

func evolve():
	current_evolution += 1
	current_animation = "level " + str(min(current_evolution, 6))
	
	var scaling_factors = {
		1: 1.5,
		2: 1.1,
		3: 0.9,
		6: 1.1
	}
	
	if current_evolution in scaling_factors.keys():
		scale *= scaling_factors[current_evolution]
	else:
		scale *= 1.08


func _on_i_frames_timeout():
	sprite.modulate = Color(1,1,1,1)
	invuln = false


func send_loadout_to_boss():
	send_loadout.emit(attack_handler)

