extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource: 
	bullet.shot_speed /= 5
	bullet.size *= 4
	
	if bullet.piercing_cooldown == 0:
		bullet.piercing_cooldown = 30
	else:
		bullet.piercing_cooldown *= 0.95
		
	bullet.damage /= 6
	bullet.piercing += 25
	bullet.fire_delay *= 2
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

