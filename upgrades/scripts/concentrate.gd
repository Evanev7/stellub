extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.shot_spread /= 4
	bullet.shot_inaccuracy /= 1.5
	bullet.damage *= 1.4
	bullet.fire_delay *= 1.25
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

