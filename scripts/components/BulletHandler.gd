extends Node

@export var bullet_scene: PackedScene

# When a bullet is fired (by the player or an enemy) this function is "called". 
# We iterate over every bullet to be fired, instantiate them and point them at the player
# OR at where the player is clicking.
func _on_fire_bullet(origin, bullet_type: BulletResource, fire_from: FireFrom):
	if not (origin is WeakRef):
		origin = weakref(origin)
	var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
		
	# Iterate over every bullet that's being fired (the number of bullets to fire
	# is stored in .multishot)
	for index in range(bullet_type.multishot):
		var bullet = bullet_scene.instantiate()
		bullet.fire_bullet.connect(_on_fire_bullet)
		
		var start_position = fire_from.position
		
		var direction_offset = inaccuracy_offset
		if bullet_type.multishot > 1:
			direction_offset += remap(index, 0, bullet_type.multishot-1, -bullet_type.shot_spread/2, bullet_type.shot_spread/2)
		var start_direction = fire_from.direction.rotated(direction_offset)
		
		# The distance from the 'firer' that the bullet starts at.
		var start_range = Vector2(bullet_type.start_range, bullet_type.start_range)
		start_range *= start_direction
		start_position += start_range
		
		bullet.direction = start_direction
		bullet.data = bullet_type
		bullet.origin_ref = origin
		bullet.position = start_position
		
		call_deferred("add_child",bullet)
		

func add(enemy):
	enemy.fire_bullet.connect(_on_fire_bullet)
