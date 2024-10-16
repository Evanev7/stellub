extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.fire_delay *= 1.05
	bullet.size *= 2
	bullet.damage *= 1.5
	if bullet.shot_inaccuracy == 0:
		bullet.shot_inaccuracy = 50
	else:
		bullet.shot_inaccuracy *= 500
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
