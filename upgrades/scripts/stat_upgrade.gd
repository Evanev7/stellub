extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.damage *= 1.1
	return bullet
