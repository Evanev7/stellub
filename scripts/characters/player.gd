extends CharacterBody2D

signal taken_damage(hp)
signal player_death
signal level_up(level)
signal send_loadout(loadout)
signal player_ready

## Player Stats
@export var STARTING_SPEED = 300.0
@export var STARTING_HP_MAX: float = 100
@export var STARTING_WEAPON: BulletResource

@export var stat_upgrade: PackedScene
@export var attack_handler: Node2D

@onready var default_scale = self.scale
var control_mode: int = 0
var level_threshold = [10, 20, 30, 50]
var current_level: int
var current_evolution: int
var current_wave: int
var souls: int
var hp_max: float
var speed
var hp
var score
var walking


var invuln: bool = false
var _h_flipped: bool = false
var current_animation


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	hide()
	$AttackHandler.stop()
	set_physics_process(false)
	player_ready.emit()

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
		
		# Walk animation
		$AnimatedSprite2D.play(current_animation)
	else:
		$AnimatedSprite2D.play(current_animation)


# When the game starts, set the default values and show the player.
func start():
	current_wave = 1
	set_default_stats()
	show()
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$AttackHandler.start()


# Set default player stats
func set_default_stats():
	## Player Stats
	speed = STARTING_SPEED
	hp_max = STARTING_HP_MAX
	hp = hp_max
	score = 0
	current_level = 0
	current_animation = "level 0"
	current_evolution = 0
	souls = 0
	scale = default_scale
	rotation = 0
	
	## Weapon Stats
	if GameState.debug:
		return
	for attack in $AttackHandler.get_children():
		attack.queue_free()
	$AttackHandler.add_attack_from_resource(STARTING_WEAPON)

func add_attack_from_resource(bullet: BulletResource):
	if control_mode == 0:
		$AttackHandler.add_attack_from_resource(bullet, Attack.CONTROL_MODE.PRIMARY)
	elif control_mode == 1:
		$AttackHandler.add_attack_from_resource(bullet, Attack.CONTROL_MODE.SECONDARY)
	elif control_mode == 2:
		$AttackHandler.add_attack_from_resource(bullet, Attack.CONTROL_MODE.TERTIARY)
	else:
		$AttackHandler.add_attack_from_resource(bullet, Attack.CONTROL_MODE.PASSIVE)
	control_mode += 1

# Called when the player gets hurt. Body can be either a bullet OR an enemy.
func hurt(body):
	if not invuln:
		hp = clamp(hp - body.damage, 0, hp_max)
		taken_damage.emit(hp)
		invuln = true
		$IFrames.start()
		$AnimatedSprite2D.modulate = Color(1,0,0,0.5)
	if hp <= 0:
		hide()
		$AttackHandler.stop()
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		$Camera2D.set_deferred("enabled", false)
		player_death.emit()


# Called when we've killed an enemy, and we can add to our score.
func gain_score(value):
	score += value
	var tween: Tween = create_tween()
	if current_level < 2:
		tween.tween_property($AnimatedSprite2D, "self_modulate:v", 1, 0.25).from(50)
	else:
		tween.tween_property($AnimatedSprite2D, "self_modulate:v", 1, 0.25).from(5)
	
	if score >= level_threshold[current_level]:
		level_up.emit(current_level)
		player_level_up()
		if level_threshold[current_level] > 2000:
			level_threshold.append(level_threshold[current_level] + 500)
		elif level_threshold[current_level] > 1000:
			level_threshold.append(level_threshold[current_level] + 200)
		elif level_threshold[current_level] > 500:
			level_threshold.append(level_threshold[current_level] + 100)
		elif level_threshold[current_level] > 200:
			level_threshold.append(level_threshold[current_level] + 50)
		elif level_threshold[current_level] > 49:
			level_threshold.append(level_threshold[current_level] + 30) 


func player_level_up():
	hp_max *= 1.02
	hp += hp_max * 0.01
	speed *= 1.02
	
	$AttackHandler.upgrade_all_attacks(stat_upgrade)


func upgrade_attack(upgrade, weapon_number):
	$AttackHandler.get_child(weapon_number).add_child(upgrade)
	$AttackHandler.get_child(weapon_number).refresh_bullet_resource()

func get_all_attacks():
	var attacks = []
	for attack in $AttackHandler.get_children():
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
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	invuln = false


func send_loadout_to_boss():
	send_loadout.emit($AttackHandler.get_child(0))
