extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	if bullet.piercing_cooldown == 0:
		bullet.piercing_cooldown = 30
	else:
		bullet.piercing_cooldown *= 0.7
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

