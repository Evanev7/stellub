extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.shot_speed = bullet.shot_speed - 400
	bullet.shot_acceleration += 900
	bullet.bullet_range *= 1.5
	bullet.damage *= 1.5
	bullet.size /= 1.25
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

