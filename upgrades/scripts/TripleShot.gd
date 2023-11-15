extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.multishot += 2
	bullet.shot_spread += PI/2.5
	return bullet
