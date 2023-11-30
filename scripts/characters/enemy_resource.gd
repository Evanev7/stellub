extends Resource

class_name EnemyResource

@export_category("Metadata")
@export var NAME: String
@export var ANIMATION: SpriteFrames
## Chance of enemy spawning
@export var QUANTITY: int = 10
@export var FLIP_H: bool
@export var FLOATING: bool

@export_category("Stats")
@export var SPEED: float
@export var MAX_HP: float
@export var DAMAGE: float
@export var VALUE: float
## How much the unit is affected by Knockback and Vacuum
@export var STRENGTH: float = 1

@export_category("Collision")
## Affects sprite and collision size
@export var SCALE: Vector2 = Vector2(2, 2)
## In Radians
@export var COLLISION_ROTATION: float = 0
@export var HITBOX: Shape2D
@export var HURTBOX: Shape2D
@export var COLLIDER: Shape2D

@export_category("Multipliers")
@export var UNIQUE_MULTIPLIER: float = 1
@export var OVERALL_MULTIPLIER: float = 1

@export_category("Bullet")
@export var BULLET: BulletResource
