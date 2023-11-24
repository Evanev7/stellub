extends Node
class_name BulletHandler

@export var bullet_scene: PackedScene
@export var max_polyphony: int = 80

var total_audio_players: int = 0
var concurrent_bullets_fired: int = 0

func _ready():
	GameState.fire_bullet.connect(_on_fire_bullet)

# When a bullet is fired (by the player or an enemy) this function is "called". 
# We iterate over every bullet to be fired, instantiate them and point them at the player
# OR at where the player is clicking.
func _on_fire_bullet(origin, bullet_type: BulletResource, fire_from: FireFrom):
	GameState.bullets_summoned += 1
	
	if total_audio_players < max_polyphony:
		play_audio(bullet_type.sound, fire_from.position)
	else:
		concurrent_bullets_fired += 1
		
		if concurrent_bullets_fired > max_polyphony / 2:
			for child in get_children():
				if child.is_in_group("bullet_audio"):
					print("Hello")
					child.stop()
					free_audio_player(child)
					play_audio(bullet_type.sound, fire_from.position)
			concurrent_bullets_fired = 0
	
	if not (origin is WeakRef):
		origin = weakref(origin)
	var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
		
	
	# Iterate over every bullet that's being fired (the number of bullets to fire
	# is stored in .multishot)
	for index in range(bullet_type.multishot):
		var bullet = bullet_scene.instantiate()
		
		var start_position = fire_from.position
		
		var direction_offset = inaccuracy_offset
		if bullet_type.multishot > 1:
			direction_offset += remap(index, 0, bullet_type.multishot-1, -bullet_type.shot_spread/2, bullet_type.shot_spread/2)
		var start_direction = fire_from.direction.normalized().rotated(direction_offset)
		
		# The distance from the 'firer' that the bullet starts at.
		var start_range = Vector2(bullet_type.start_range, bullet_type.start_range)
		start_range *= start_direction
		start_position += start_range
		
		bullet.direction = start_direction
		bullet.data = bullet_type
		bullet.origin_ref = origin
		bullet.position = start_position
		bullet.transport(0)
		
		call_deferred("add_child",bullet)
		
func play_audio(sound, pos):
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = sound
	audio_player.position = pos
	audio_player.bus = "SFX"
	audio_player.finished.connect(Callable(free_audio_player).bind(audio_player))
	add_child(audio_player)
	audio_player.play()
	add_to_group("bullet_audio")
	total_audio_players += 1
	
func free_audio_player(audio_player):
	audio_player.queue_free()
	total_audio_players -= 1
