extends Node
class_name Upgrade

## 1 is default
@export var rarity: float = 1.0
@export var icon: CompressedTexture2D
@export_multiline var description: String
@export var skip: bool = false
var script_data: Dictionary
var upgrade_name

enum TYPE {STAT, BOSS, SHOP}
@export var type: TYPE = TYPE.SHOP

func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass


func modify_toplevel(bullet: BulletResource) -> BulletResource:
	return bullet
