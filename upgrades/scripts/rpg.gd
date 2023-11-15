extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.shot_speed = clamp(bullet.shot_speed - 400, 10, bullet.shot_speed)
	bullet.shot_acceleration += 900
	bullet.range *= 1.5
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

