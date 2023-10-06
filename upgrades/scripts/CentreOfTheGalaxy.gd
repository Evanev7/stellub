extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.multishot *= 4
	bullet.shot_inaccuracy = 0
	bullet.shot_spread = 2*PI
	bullet.angular_velocity = 1.5*PI
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

