extends Resource

class_name BulletResource

@export var animation: SpriteFrames

@export var start_range: int = 0
@export var lifetime: float = 20.0
@export var bullet_range: int = 1000
@export var damage: int = 1
@export var fire_delay: int = 15
@export var multishot: int = 1
@export var size: Vector2 = Vector2(1, 1)
@export var shot_spread: float =  PI/12

## 2*PI for a full circle
@export var shot_inaccuracy: float = PI/32
@export var shot_speed: float = 400

## Bullet type that will spawn from this bullet
@export var spawned_bullet_resource: BulletResource

#@export var starting_start_range: int = 0
#
### In seconds
#@export var starting_lifetime: float = 20
#@export var starting_bullet_range: int = 1000
#@export var starting_damage: int = 1
#@export var starting_fire_delay: int = 15
#@export var starting_multishot: int = 1
#@export var starting_size := Vector2(1, 1)
#
### Format: PI/x, default PI/12, 2*PI creates a circle
#@export var starting_shot_spread: float = PI/12
#
### Format: PI/x, default PI/32
#@export var starting_shot_inaccuracy: float = PI/32
#
#@export var starting_shot_speed: float = 400
#
#var start_range = starting_start_range
#var lifetime = starting_lifetime
#var bullet_range = starting_bullet_range
#var damage =  starting_damage
#var fire_delay = starting_fire_delay
#var multishot = starting_multishot
#var size = starting_size
#var shot_spread =  starting_shot_spread
#var shot_inaccuracy = starting_shot_inaccuracy
#var shot_speed = starting_shot_speed
