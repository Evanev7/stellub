extends CharacterBody2D

signal taken_damage
signal player_death
signal fire_bullet

@export var SPEED = 200.0
@export var ROTATION_SPEED = 20
@export var fire_rate: int = 1
var screen_size: Vector2i
var HP_MAX: int = 50
var hp
var firing
var _fire_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	if not screen_size:
		screen_size = get_viewport_rect().size
	hide()
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		
		var angle_difference = velocity.angle() - rotation + PI/2
		
		angle_difference = fposmod(angle_difference + PI, 2*PI)-PI
		
		if ROTATION_SPEED * delta > abs(angle_difference):
			rotation += angle_difference
		else: 
			rotation += ROTATION_SPEED * delta * sign(angle_difference)
		
		move_and_slide()
		
		# Walk animation
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.pause()
	
	if Input.is_action_just_pressed("primary_fire"):
		firing = true
	if Input.is_action_just_released("primary_fire"):
		firing = false
	if firing:
		_fire_timer += fire_rate
		while _fire_timer >= 1:
			fire_bullet.emit()
			_fire_timer -= 1
		
	

func start(pos):
	position = pos
	show()
	hp = HP_MAX
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$Camera2D.enabled = true
	


func hit(body):
	hp -= 1
	taken_damage.emit()
	if hp <= 0:
		hide()
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		$Camera2D.set_deferred("enabled", false)
		player_death.emit()

