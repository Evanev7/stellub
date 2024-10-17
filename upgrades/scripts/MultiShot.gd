extends Upgrade


func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.multishot += 1
	bullet.shot_spread += PI/4
	return bullet
