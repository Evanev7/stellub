extends Upgrade



# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	if bullet.knockback == 0:
		bullet.knockback = 1
	bullet.knockback *= 20
	return bullet


