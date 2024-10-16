extends Upgrade

	
# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.bullet_range /= 10
	bullet.damage *= 2
	return bullet
