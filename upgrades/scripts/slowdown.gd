extends Upgrade

	
# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.shot_speed -= 400
	return bullet
