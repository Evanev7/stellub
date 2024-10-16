extends Upgrade

var detonator_bullet: BulletResource
var original_bullet: BulletResource
#
func _ready():
	rarity = 2


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	detonator_bullet = script_data["bullet"].duplicate()
	original_bullet = bullet
	detonator_bullet.fire_delay = bullet.fire_delay
	return detonator_bullet


# Used for code to execute before firing
func pre_fire():
	detonator_bullet.spawned_bullet_resource = original_bullet
	pass
