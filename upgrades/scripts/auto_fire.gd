extends Upgrade


#
func _ready():
	pass


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	get_parent().control_mode = get_parent().CONTROL_MODE.PASSIVE
	bullet.fire_delay *= 1.05
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass

