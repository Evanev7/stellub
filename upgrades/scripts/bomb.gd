extends Upgrade

var bomb_bullet
#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bomb_bullet = script_data["bullet"].duplicate()
	bomb_bullet.spawned_bullet_resource = bullet.spawned_bullet_resource
	bullet.spawned_bullet_resource = bomb_bullet
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

