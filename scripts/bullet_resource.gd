extends Resource

class_name BulletResource

@export var source: String
@export var animation: SpriteFrames
@export var speed: float = 400
@export var lifetime: int = 20
@export var bullet_range: int = 1000
@export var damage: int = 1


@export var fire_delay: int = 15
@export var multishot: int = 1
@export var shot_spread: float = PI/12
@export var shot_inaccuracy: float = PI/32
@export var shot_speed: float = 0.99

