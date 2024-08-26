extends Upgrade


#
func _ready():
	type = TYPE.BOSS
	pass


# Change stats on pickup
func modify_toplevel(bullet: BulletResource) -> BulletResource:
	bullet.deactivation_range *= 50
	bullet.bullet_range *= 2
	bullet.start_range *= 2
	bullet.size *= 3
	bullet.damage *= 2
	bullet.angular_velocity /= 5
	if bullet.spawned_bullet_resource:
		bullet.spawned_bullet_resource = modify_toplevel(bullet.spawned_bullet_resource)
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
