extends Upgrade


func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.splits += 1

	var split_shot: BulletResource = bullet.duplicate()
	split_shot.damage /= 2
	split_shot.size /= 1.8
	split_shot.multishot = int(2 + bullet.splits / 3)
	split_shot.shot_spread = PI
	split_shot.activation_delay = 0.2
	split_shot.sound = script_data["bullet"]
	split_shot.spawned_bullet_resource = bullet.spawned_bullet_resource
	bullet.spawned_bullet_resource = split_shot

	return bullet
