extends Upgrade

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	var split_shot: BulletResource = bullet.duplicate()
	split_shot.damage /= 2
	split_shot.size /= 1.8
	split_shot.multishot = 2
	split_shot.shot_spread = PI
	split_shot.activation_delay = 0.1
	split_shot.spawned_bullet_resource = split_shot
	bullet.spawned_bullet_resource = split_shot
	return bullet
