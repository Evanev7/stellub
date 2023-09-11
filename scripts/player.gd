extends CharacterBody2D

signal taken_damage
signal enemy_killed
signal player_death
signal level_up
signal fire_bullet(bullet: BulletResource)

## Player Stats
@export var STARTING_SPEED = 380.0
@export var STARTING_ROTATION_SPEED = 20
@export var STARTING_HP_MAX: int = 100

@export var bullet: BulletResource

var level_threshold = [10, 20, 30, 50, 80, 130, 210, 340, 550, 999]
var current_level
var hp_max
var speed
var rotation_speed
var hp
var score
var firing
var walking
var default_scale
var _fire_timer: float = 0.0
var _h_flipped: bool = false
var current_animation


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	default_scale = self.scale
	hide()
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	
	##Debug ###############################
	
	if Input.is_key_pressed(KEY_R): ## Increase score by 10
		on_enemy_killed(10)
	
	#######################################
	
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
		
		if velocity.x < 0 and not _h_flipped:
			scale = Vector2i(-1,1)
			_h_flipped = true
		elif velocity.x > 0 and _h_flipped:
			scale = Vector2i(-1,-1)
			_h_flipped = false
		
		move_and_slide()
		
		# Walk animation
		$AnimatedSprite2D.play(current_animation)
	else:
		$AnimatedSprite2D.play(current_animation)
	
	if _fire_timer <= bullet.fire_delay:
		_fire_timer += 1
	
	if firing and _fire_timer >= bullet.fire_delay:
		fire_bullet.emit(self, bullet)
		_fire_timer -= bullet.fire_delay
	
	for area in $Hurtbox.get_overlapping_areas():
		process_hurtbox(area)


func start(pos):
	default_stats()
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
	current_animation = "level 0"


func hurt(body):
	hp -= body.damage
	taken_damage.emit()
	if hp <= 0:
		hide()
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		$Camera2D.set_deferred("enabled", false)
		player_death.emit()


func on_enemy_killed(value):
	score += value
	enemy_killed.emit()
	
	if current_level < 10 and score >= level_threshold[current_level]:
		current_level += 1
		level_up.emit(current_level)


func process_hurtbox(area):
	if area.is_in_group("bullet"):
		if area.origin != GameState.player:
			hurt(area.data)
			area.queue_free()
		return
	if area.owner.is_in_group("enemy"):
			hurt(area.owner)
