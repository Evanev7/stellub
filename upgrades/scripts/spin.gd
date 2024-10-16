extends Upgrade


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.transport_mode = BulletResource.TRANSPORT_MODE.ROTATING_NO_CENTRE
	if bullet.angular_velocity == 0:
		bullet.angular_velocity = 1
	else:
		bullet.angular_velocity *= 1.2
	return bullet
