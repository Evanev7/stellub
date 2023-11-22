extends Upgrade



func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource: 
	bullet.shot_speed /= 2
	bullet.size *= 1.5
	
	if bullet.piercing_cooldown == 0:
		bullet.piercing_cooldown = 15
	else:
		bullet.piercing_cooldown *= 0.7
		
	bullet.damage /= 2
	bullet.piercing += 4
	bullet.fire_delay *= 2
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

