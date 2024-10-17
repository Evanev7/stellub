extends Node
class_name Upgrade

var rarity: int
var icon: CompressedTexture2D
var description: String
var skip: bool = false
var script_data: Dictionary
var upgrade_name: String

enum TYPE {STAT, BOSS, SHOP}
var type: TYPE = TYPE.SHOP

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
