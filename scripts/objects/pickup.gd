extends Area2D
class_name Pickup

@export var launch_angle: float = PI/6
@export var launch_velocity: float = 250
@export var activation_time: float = 2
@export var grav_scale: float = 5
@export var speed: float = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum {xp_pickup, hp_pickup, vacuum_pickup, freeze_pickup, fire_pickup}
var pickup_type: int

var value: int = 1

var activated: bool = false
var collected: bool = false
var lifetime: float = 0
var velocity: float = 0

func _ready():
	match pickup_type:
		xp_pickup:
			GameState.num_xp_pickups += 1
			sprite.animation = "xp_pickup"
			sprite.scale = Vector2(0.1, 0.1)
			add_to_group("xp_pickup")
			var scale_ratio = 0.6+log(value)
			apply_scale(Vector2(scale_ratio, scale_ratio))
		hp_pickup:
			sprite.animation = "hp_pickup"
			value = randi() % 31 + 5
		vacuum_pickup:
			sprite.animation = "vacuum_pickup"
		freeze_pickup:
			sprite.animation = "freeze_pickup"
			## temp
			sprite.modulate = Color(0, 0.3, 1)
			value = randi() % 6 + 3
		fire_pickup:
			sprite.animation = "fire_pickup"
			sprite.modulate = Color(1, 0, 0)
			value = randi() % 10 + 3
	sprite.play()

	#Randomly distribute launch_angle according to proper distribution
	launch_angle = (randi_range(0,1)*2-1)*acos(1-randf()*(1-cos(launch_angle)))
	add_to_group("pickup")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if lifetime < activation_time:
		lifetime += delta
		var direction = Vector2.from_angle(launch_angle- PI/2)
		position += launch_velocity * direction * delta + Vector2(0,lifetime*grav_scale)
	if activated:
		var direction = (GameState.player.position - position).normalized()
		velocity += speed
		position += velocity * direction * delta

func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	activated = true

	# Add functionality to add value to another nearby pickup

func _notification(what):
	if what == NOTIFICATION_PREDELETE and pickup_type == xp_pickup:
		GameState.num_xp_pickups -= 1
