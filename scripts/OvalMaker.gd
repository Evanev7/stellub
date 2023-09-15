extends Node

@export var samples: int = 100
@export var axis: Vector2 = Vector2(10,10)
@export var collisionshape: CollisionPolygon2D


func _ready():
	var oval: PackedVector2Array
	for index in range(samples):
		var angle = remap(index, 0, samples, 0, 2*PI)
		oval.append(Vector2.from_angle(angle) * axis)
	collisionshape.polygon = oval
		
