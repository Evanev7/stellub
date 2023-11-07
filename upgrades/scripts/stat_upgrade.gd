extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.damage *= 1.01
	bullet.size *= 1.005
	bullet.fire_delay *= 0.98
	if bullet.fire_delay < 0.2:
		bullet.fire_delay = 0
		if randf() > 0.9:
			bullet.multishot += 1
	return bullet

func pre_fire():
	pass
