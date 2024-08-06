extends Upgrade


#
func _ready():
	type = TYPE.BOSS
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.deactivation_range *= 50
	bullet.bullet_range *= 5
	bullet.start_range *= 2
	bullet.size *= 3
	bullet.damage *= 2
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

