extends CharacterBody2D

signal taken_damage(hp)
signal player_death
signal level_up(level)

## Player Stats
@export var STARTING_SPEED = 300.0
@export var STARTING_HP_MAX: int = 100

@export var starting_bullet_list: Array[BulletResource]
@export var starting_passive_bullet_list: Array[BulletResource]

@onready var default_scale = self.scale
@onready var passive_attack_1: PlayerAttack = $Passive_Attack_1
@onready var passive_attack_2: PlayerAttack = $Passive_Attack_2
@onready var passive_attack_3: PlayerAttack = $Passive_Attack_3

var level_threshold = [10, 20, 30, 50]
var current_level
var current_evolution
var current_wave
var souls
var hp_max
var speed
var hp
var score
var walking


var invuln: bool = false
var _h_flipped: bool = false
var current_animation

var bullets
var passive_bullets
var all_bullets
var firing_one
var firing_two
var firing_three
var fire_timer_one: int = 0
var fire_timer_two: int = 0
var fire_timer_three: int = 0
var fire_timer_passive_one: int = 0
var fire_timer_passive_two: int = 0
var fire_timer_passive_three: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = self
	hide()
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	velocity.y = Input.get_axis("move_up", "move_down")
	
#	if Input.is_key_pressed(KEY_T):
#		bullets[2] = starting_bullet
	
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
	
	if Input.is_action_just_pressed("primary_fire"):
		firing_one = true
	if Input.is_action_just_released("primary_fire"):
		firing_one = false
		
	if Input.is_action_just_pressed("secondary_fire"):
		firing_two = true
	if Input.is_action_just_released("secondary_fire"):
		firing_two = false
		
	if Input.is_action_just_pressed("tertiary_fire"):
		firing_three = true
	if Input.is_action_just_released("tertiary_fire"):
		firing_three = false

	
	# If we aren't ready to fire yet - just increment the fire_timer
	if bullets[0] and fire_timer_one < bullets[0].fire_delay:
		fire_timer_one += 1
		#$ShotRecharge.value = fire_timer_one
		
	if bullets[1] and fire_timer_two < bullets[1].fire_delay:
		fire_timer_two += 1
		#$ShotRecharge.value = fire_timer_two
		
	if bullets[2] and fire_timer_three < bullets[2].fire_delay:
		fire_timer_three += 1
		#$ShotRecharge.value = fire_timer_three
	
	if bullets[0] and firing_one and fire_timer_one >= bullets[0].fire_delay:
		var fire_from = FireFrom.new()
		fire_from.toward(position, get_global_mouse_position())
		GameState.fire_bullet.emit(self, bullets[0], fire_from)
		fire_timer_one -= bullets[0].fire_delay
		
	if bullets[1] and firing_two and fire_timer_two >= bullets[1].fire_delay:
		var fire_from = FireFrom.new()
		fire_from.toward(position, get_global_mouse_position())
		GameState.fire_bullet.emit(self, bullets[1], fire_from)
		fire_timer_two -= bullets[1].fire_delay
		
	if bullets[2] and firing_three and fire_timer_three >= bullets[2].fire_delay:
		var fire_from = FireFrom.new()
		fire_from.toward(position, get_global_mouse_position())
		GameState.fire_bullet.emit(self, bullets[2], fire_from)
		fire_timer_three -= bullets[2].fire_delay


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
	#$ShotRecharge.max_value = bullet.fire_delay
	scale = default_scale
	rotation = 0
	
	## Weapon Stats
	bullets = starting_bullet_list.duplicate(true)
	passive_bullets = starting_passive_bullet_list.duplicate(true)
	passive_attack_1.bullet = passive_bullets[0]
	passive_attack_2.bullet = passive_bullets[1]
	passive_attack_3.bullet = passive_bullets[2]
	
	all_bullets = []
	for bullet_list in [bullets, passive_bullets]:
		for i in range(bullet_list.size()):
			var bullet = bullet_list[i]
			if bullet:
				all_bullets.append(bullet)
	
	print("player")
	print(all_bullets)
	
func add_weapon(weapon):
	if weapon.control == "right" and not bullets[1]:
		bullets[1] = weapon
	elif weapon.control == "space" and not bullets[2]:
		bullets[2] = weapon
	else:
		print("filled")
	
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
	current_animation = "level " + str(min(current_evolution, 6))
	
	var scaling_factors = {
		1: 1.5,
		2: 1.1,
		3: 0.9,
		6: 1.1
	}
	
	if current_evolution in scaling_factors:
		scale *= scaling_factors[current_evolution]
	else:
		scale *= 1.08

func stat_upgrade(stat):
	for bullet in all_bullets:
		if bullet:
			if stat == "Piercing":
				bullet.piercing += 1
			if stat == "Multi Shot":
				bullet.multishot += 1
			if stat == "Movement Speed":
				self.speed *= 1.1
			if stat == "Shot Speed":
				bullet.shot_speed *= 1.1
			if stat == "Fire Rate":
				bullet.fire_delay /= 1.1
			if stat == "Piercing Frequency":
				bullet.piercing_cooldown /= 1.1
			if stat == "Shot Size":
				bullet.size *= 1.1

func _on_i_frames_timeout():
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	invuln = false
