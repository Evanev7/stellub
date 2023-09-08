extends CharacterBody2D

signal taken_damage
signal enemy_killed
signal player_death
signal fire_bullet(number,spread,inaccuracy)

@export var SPEED = 380.0
@export var ROTATION_SPEED = 20
@export var HP_MAX: int = 100
@export var fire_delay: int = 15
@export var multishot: int = 3
@export var shot_spread: float = PI/12
@export var shot_inaccuracy: float = PI/32

var screen_size: Vector2i
var hp
var score
var firing
var walking
var _fire_timer: float = 0.0
var direction

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	if not screen_size:
		screen_size = get_viewport_rect().size
	hide()
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	
	if Input.is_action_just_pressed("walk"):
		walking = true
	if Input.is_action_just_released("walk"):
		walking = false
		
	if Input.is_action_just_pressed("primary_fire"):
		firing = true
	if Input.is_action_just_released("primary_fire"):
		firing = false
	
	direction = sign(get_global_mouse_position().x - self.global_position.x)
	if direction < 0:
		$AnimatedSprite2D.set_flip_h(true)
#		$CollisionShape2D.set_flip_h(true)
#		$Hurtbox/CollisionShape2D2.set_flip_h(true)
	else:
		$AnimatedSprite2D.set_flip_h(false)
#		$CollisionShape2D.set_flip_h(false)
#		$Hurtbox/CollisionShape2D2.set_flip_h(false)
	
	if velocity.length() > 0:
		if walking == true:
			velocity = velocity.normalized() * SPEED/2
		else:
			velocity = velocity.normalized() * SPEED
		
		var angle_difference = velocity.angle() - rotation + PI/2
		
		angle_difference = fposmod(angle_difference + PI, 2*PI)-PI

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
<<<<<<< Updated upstream
=======
	default_stats()
	for i in level_threshold:
		level_cap.append(i + i/2)
	current_level = 0
>>>>>>> Stashed changes
	position = pos
	show()
	hp = HP_MAX
	score = 0
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$Camera2D.enabled = true
	
func default_stats():
	## Player Stats
	SPEED = 380.0
	ROTATION_SPEED = 20
	HP_MAX = 100
	
	## Weapon Stats
	fire_delay = 15
	multishot = 1
	shot_spread = PI/12
	shot_inaccuracy = PI/32

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
<<<<<<< Updated upstream
	enemy_killed.emit()
=======
	var index = 0
	for i in level_threshold:
		index += 1
		if score >= i:
			for j in level_cap:
				if index <= current_level:
					break
				if score < j:
					current_level = index
					next_level(current_level)
	enemy_killed.emit()
	
func next_level(level):
	level_up.emit(level)
>>>>>>> Stashed changes

