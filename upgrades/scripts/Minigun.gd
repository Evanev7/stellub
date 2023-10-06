extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.fire_delay /= 6
	bullet.damage /= 6
	bullet.shot_inaccuracy *= 4
	bullet.size /= 2
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

