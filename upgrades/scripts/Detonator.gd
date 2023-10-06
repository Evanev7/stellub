extends Upgrade

@export var detonator_bullet: BulletResource

#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	detonator_bullet.spawned_bullet_resource = bullet
	detonator_bullet.fire_delay = bullet.fire_delay
	return detonator_bullet


# Used for code to execute before firing
func pre_fire():
	pass

