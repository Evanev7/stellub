extends Node
class_name Upgrade

## 1 is default
@export var rarity: float = 1.0
@export var icon: CompressedTexture2D


func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
