extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource: 
	bullet.shot_speed /= 5
	bullet.size *= 4
	bullet.piercing_cooldown = 6
	bullet.damage /= 6
	bullet.piercing = 50
	bullet.fire_delay *= 4
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

