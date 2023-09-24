extends CharacterBody2D

signal taken_damage(hp)
signal player_death
signal level_up(level)

## Player Stats
@export var STARTING_SPEED = 300.0
@export var STARTING_HP_MAX: int = 100
@export var starting_bullet: BulletResource

@onready var default_scale = self.scale

var level_threshold = [10, 20, 30, 50]
var current_level
var current_evolution
var current_wave
var souls
var hp_max
var speed
var hp
var score
var firing
var walking

var invuln: bool = false
var _fire_timer: int = 0
var _h_flipped: bool = false
var current_animation

var bullet


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	# Hide the player when we start the game
	hide()
	set_physics_process(false)
	bullet = starting_bullet.duplicate(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	
	# Handle user input
	if Input.is_action_just_pressed("walk"):
		walking = true
	if Input.is_action_just_released("walk"):
		walking = false
		
	if Input.is_action_just_pressed("primary_fire"):
		firing = true
	if Input.is_action_just_released("primary_fire"):
		firing = false
	
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
	
	# If we aren't ready to fire yet - just increment the fire_timer
	if _fire_timer < bullet.fire_delay:
		_fire_timer += 1
		$ShotRecharge.value = _fire_timer
	
	if firing and _fire_timer >= bullet.fire_delay:
		var fire_from = FireFrom.new()
		fire_from.toward(position, get_global_mouse_position())
		GameState.fire_bullet.emit(self, bullet, fire_from)
		_fire_timer -= bullet.fire_delay

# When the game starts, set the default values and show the player.
func start():
	set_default_stats()
	current_wave = 1
	show()
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$Camera2D.enabled = true

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
	$ShotRecharge.max_value = bullet.fire_delay
	scale = default_scale
	rotation = 0
	
	## Weapon Stats
	bullet = starting_bullet.duplicate(true)

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
	
	# TODO: At the moment, we can't level up past level 10 (without cheating).
	if score >= level_threshold[current_level]:
		level_up.emit(current_level)
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
			
func evolve():
	current_animation = "level " + str(current_evolution)
	if current_level < 2:
		scale *= 1.3
	else:
		scale *= 1.1

func stat_upgrade(stat):
	if stat == "Piercing":
		bullet.piercing += 1
	if stat == "Multi Shot":
		bullet.multishot += 1
	if stat == "Movement Speed":
		self.speed *= 1.1
	if stat == "Shot Speed":
		bullet.shot_speed *= 1.1
	if stat == "Fire Delay":
		bullet.fire_delay /= 1.1

func _on_i_frames_timeout():
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	invuln = false
