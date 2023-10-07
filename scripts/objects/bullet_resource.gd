extends Resource

class_name BulletResource

@export var animation: SpriteFrames

@export var name: String

@export var start_range: int = 0
@export var lifetime: float = 20.0
@export var bullet_range: int = 1000
@export var damage: float = 1
@export var fire_delay: float = 15
@export var multishot: int = 1
@export var size: Vector2 = Vector2(1, 1)
@export var colour: Color = Color(1,1,1,1)
@export var shot_spread: float =  PI/12
@export var angular_velocity: float = 0
@export var piercing: int = 1
@export var piercing_cooldown: int = 0
@export var activation_delay: float = 0
@export var deactivation_range: int = 500

## 2*PI for a full circle
@export var shot_inaccuracy: float = PI/32

## Set to 0 to make bullets follow the source
@export var shot_speed: float = 400

## Bullet type that will spawn from this bullet
@export var spawned_bullet_resource: BulletResource
@export var spawn_on_timeout: bool = false
