extends CharacterBody2D

signal taken_damage(hp)
signal player_death
signal level_up(level)
signal fire_bullet(origin, bullet: BulletResource, init: FireFrom)

## Player Stats
@export var STARTING_SPEED = 380.0
@export var STARTING_ROTATION_SPEED = 20
@export var STARTING_HP_MAX: int = 100
@export var bullet: BulletResource

@onready var default_scale = self.scale

var level_threshold = [10, 20, 30, 50, 80, 130, 210, 340, 550, 999]
var current_level
var hp_max
var speed
var rotation_speed
var hp
var score
var firing
var walking

var invuln: bool = false
var _fire_timer: float = 0.0
var _h_flipped: bool = false
var current_animation


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	# Hide the player when we start the game
	hide()
	set_physics_process(false)

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
	
	if firing and _fire_timer >= bullet.fire_delay:
		var fire_from = FireFrom.new()
		fire_from.toward(position, get_global_mouse_position())
		fire_bullet.emit(self, bullet, fire_from)
		_fire_timer -= bullet.fire_delay

# When the game starts, set the default values and show the player.
func start():
	set_default_stats()
	show()
	set_physics_process(true)
	hp = hp_max
	score = 0
	current_level = 0
	$CollisionShape2D.disabled = false
	$Camera2D.enabled = true

# Set default player stats
func set_default_stats():
	## Player Stats
	speed = STARTING_SPEED
	rotation_speed = STARTING_ROTATION_SPEED
	hp_max = STARTING_HP_MAX
	current_animation = "level 0"
	scale = default_scale

# Called when the player gets hurt. Body can be either a bullet OR an enemy.
func hurt(body):
	if not invuln:
		hp -= body.damage
		if hp < 0:
			hp = 0
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
	if current_level < 10 and score >= level_threshold[current_level]:
		level_up.emit(current_level)
		if current_level % 1 == 0:
			current_animation = "level " + str(current_level/1)

func _on_i_frames_timeout():
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	invuln = false
