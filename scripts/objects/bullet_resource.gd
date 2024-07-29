extends Resource

class_name BulletResource

enum TRANSPORT_MODE {LINEAR, ROTATING_FIXED_CENTRE, ROTATING_NO_CENTRE, ROTATING_LINEAR_CENTRE, STATIC}
enum TARGET_MODE {PLAYER, MOUSE, NEAREST_ENEMY}
enum FACING_DIRECTION {DEFAULT, UP, DOWN, LEFT, RIGHT}

@export_category("Metadata")
@export var name: String
@export_multiline var description: String = "Default Upgrade Description"
@export var animation: SpriteFrames
@export var sound: AudioStreamRandomizer
@export var rarity: float = 1
@export var icon: SpriteFrames
@export var size: Vector2 = Vector2(1, 1)
@export var colour: Color = Color(1,1,1,1)
@export var fire_on_hit: bool = false

@export_category("Shooting Stats")
@export var start_range: int = 0
## Float in seconds
@export var lifetime: float = 1.0
@export var bullet_range: float = 1000
@export var fire_delay: float = 15
@export var shot_speed: float = 400
@export var can_be_negative: bool = false
@export var shot_acceleration: float = 0

## 2*PI for a full circle
@export var shot_spread: float =  PI/12
@export var shot_inaccuracy: float = PI/32
@export var multishot: int = 1

@export_category("Projectile Stats")
@export var damage: float = 1
@export var transport_mode: TRANSPORT_MODE = TRANSPORT_MODE.LINEAR
@export var target_mode: TARGET_MODE = TARGET_MODE.MOUSE
@export var facing_direction: FACING_DIRECTION = FACING_DIRECTION.DEFAULT
@export var activation_delay: float = 0
@export var angular_velocity: float = 0
@export var piercing: int = 1
@export var piercing_cooldown: float = 0
@export var knockback: float = 0
@export var splits: int = 1

@export_category("Enemy Deactivation")
@export var deactivation_range: int = 500

@export_category("Vacuum")
## Suck stuff
@export var vacuum: bool = false
@export var vacuum_range: float = 100
@export var vacuum_strength: float = 1

@export_category("Bullet Spawning")

## Bullet type that will spawn from this bullet
@export var spawned_bullet_resource: BulletResource
@export var spawn_on_timeout: bool = false
