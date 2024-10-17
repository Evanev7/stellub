extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.vacuum = true
	bullet.vacuum_range += 30
	bullet.vacuum_strength += 1
	bullet.activation_delay = 0.5
	bullet.piercing += 2
	bullet.shot_acceleration -= 0.1

	if bullet.piercing_cooldown == 0:
		bullet.piercing_cooldown = 50
	else:
		bullet.piercing_cooldown *= 0.95
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
