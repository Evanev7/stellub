extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.multishot *= 3
	if bullet.shot_spread < PI/2:
		bullet.shot_spread = PI/2
	return bullet
