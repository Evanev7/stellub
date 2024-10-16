extends Upgrade

var frag_bullet
#
func _ready():
	rarity = 3


# Change stats on pickup
func modify_bullet_resource(bullet: BulletResource) -> BulletResource:
	frag_bullet = script_data["bullet"].duplicate()
	frag_bullet.spawned_bullet_resource = bullet.spawned_bullet_resource
	bullet.spawned_bullet_resource = frag_bullet
	return bullet


# Used for code to execute before firing
func pre_fire():
	pass
