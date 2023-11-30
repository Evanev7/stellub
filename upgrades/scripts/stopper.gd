extends Upgrade



# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.can_be_negative = false
	return bullet


