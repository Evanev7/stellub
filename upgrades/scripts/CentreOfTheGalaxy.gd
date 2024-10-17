extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.transport_mode = bullet.TRANSPORT_MODE.ROTATING_FIXED_CENTRE
	bullet.start_range = 250
	bullet.fire_delay *= 1.2
	bullet.multishot *= 2
	bullet.shot_inaccuracy = 0
	bullet.shot_spread = PI
	bullet.angular_velocity = 1.5*PI
	bullet.bullet_range += 500
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
