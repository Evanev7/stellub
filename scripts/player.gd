extends CharacterBody2D

signal taken_damage
signal enemy_killed
signal player_death
signal level_up
signal fire_bullet(number,spread,inaccuracy)

@export var STARTING_SPEED = 380.0
@export var STARTING_ROTATION_SPEED = 20
@export var STARTING_HP_MAX: int = 100
@export var STARTING_fire_delay: int = 15
@export var STARTING_multishot: int = 1

## Format: PI/x, default PI/12
@export var STARTING_shot_spread: float = PI/12

## Format: PI/x, default PI/32
@export var STARTING_shot_inaccuracy: float = PI/32

var screen_size: Vector2i
var level_threshold = [10, 20, 30, 50, 80, 130, 210, 340, 550, 999]
var level_cap = []
var current_level
var hp_max
var speed
var rotation_speed
var fire_delay
var multishot
var shot_spread
var shot_inaccuracy
var hp
var score
var firing
var walking
var default_scale
var _fire_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	default_scale = self.scale
	if not screen_size:
		screen_size = get_viewport_rect().size
	hide()
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	
	##Debug ###############################
	
	if Input.is_key_pressed(KEY_R): ## Increase score by 10
		hit(10)
	
	
	#######################################
	
	if Input.is_action_just_pressed("walk"):
		walking = true
	if Input.is_action_just_released("walk"):
		walking = false
		
	if Input.is_action_just_pressed("primary_fire"):
		firing = true
	if Input.is_action_just_released("primary_fire"):
		firing = false

#	if self.velocity.x == -1:
#		self.scale = Vector2(-default_scale.x, default_scale.y)
#	elif self.velocity.x == 1:
#		self.scale = default_scale
	
	if velocity.length() > 0:
		if walking == true:
			velocity = velocity.normalized() * speed/2
		else:
			velocity = velocity.normalized() * speed
		
#		var angle_difference = velocity.angle() - rotation + PI/2
#
#		angle_difference = fposmod(angle_difference + PI, 2*PI)-PI
#		
#		if ROTATION_SPEED * delta > abs(angle_difference):
#			rotation += angle_difference
#		else: 
#			rotation += ROTATION_SPEED * delta * sign(angle_difference)
		
		move_and_slide()
		
		# Walk animation
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.pause()
	
	if firing:
		_fire_timer += 1
		while _fire_timer >= fire_delay:
			fire_bullet.emit(multishot, shot_spread, shot_inaccuracy)
			_fire_timer -= fire_delay
	
	for area in $Hurtbox.get_overlapping_areas():
		if area.owner.is_in_group("enemy"):
			hurt(area.owner)


func start(pos):
	default_stats()
	for i in level_threshold:
		level_cap.append(i + i/2)
	current_level = 0
	position = pos
	show()
	hp = hp_max
	score = 0
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$Camera2D.enabled = true

func default_stats():
	## Player Stats
	speed = STARTING_SPEED
	rotation_speed = STARTING_ROTATION_SPEED
	hp_max = STARTING_HP_MAX
	
	## Weapon Stats
	fire_delay = STARTING_fire_delay
	multishot = STARTING_multishot
	shot_spread = STARTING_shot_spread
	shot_inaccuracy = STARTING_shot_inaccuracy
	

func hurt(body):
	hp -= body.damage
	taken_damage.emit()
	if hp <= 0:
		hide()
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		$Camera2D.set_deferred("enabled", false)
		player_death.emit()
		
func hit(value):
	score += value
	var index = 0
	for i in level_threshold:
		index += 1
		if score >= i:
			for j in level_cap:
				if index <= current_level:
					break
				if score < j:
					current_level = index
					on_level_up(current_level)
	enemy_killed.emit()
	
func on_level_up(level):
	level_up.emit(level)
