extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.damage *= 1.1
	bullet.size *= 1.02
	bullet.fire_delay *= 0.95
	if bullet.fire_delay < 0.2:
		bullet.fire_delay = 0
		if randf() > 0.9:
			bullet.multishot += 1
	return bullet
