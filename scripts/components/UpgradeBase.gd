extends Node
class_name Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
