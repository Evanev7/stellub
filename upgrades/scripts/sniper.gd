extends Upgrade



# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.shot_speed += 500
	bullet.bullet_range += 500
	return bullet



