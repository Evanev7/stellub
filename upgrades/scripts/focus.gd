extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.multishot = clamp(bullet.multishot - 1, 0, bullet.multishot)
	bullet.damage *= 2
	return bullet
