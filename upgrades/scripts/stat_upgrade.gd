extends Upgrade

func _ready():
	skip = true

func global_second_pass(bullet: BulletResource) -> BulletResource:
	bullet.damage *= 1.015
	bullet.size *= 1.01
	bullet.shot_speed *= 1.01
	bullet.fire_delay *= 0.98
	if bullet.fire_delay < 0.2:
		bullet.fire_delay = 0
	if bullet.spawned_bullet_resource:
		bullet.spawned_bullet_resource = global_second_pass(bullet.spawned_bullet_resource)
	
	return bullet

func pre_fire():
	pass
