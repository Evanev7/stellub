extends Upgrade

func _ready():
	skip = true

func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	bullet.damage *= 1.015
	bullet.size *= 1.01
	bullet.shot_speed *= 1.01
	bullet.fire_delay *= 0.98
	if bullet.fire_delay < 0.2:
		bullet.fire_delay = 0
	return bullet

func pre_fire():
	pass
