extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.knockback /= 2
	bullet.fire_delay /= 4
	bullet.damage /= 2
	bullet.shot_inaccuracy *= 4
	bullet.size /= 1.3
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

