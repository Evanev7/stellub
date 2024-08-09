extends Node
class_name BulletHandler

@export var bullet_scene: PackedScene
@export var max_polyphony: int = 80

@onready var bullets_parent: Node = $Bullets
@onready var audio_players_parent: Node = $AudioPlayers

var total_audio_players: int = 0
var concurrent_bullets_fired: int = 0

var bullet_scene_pool: Array[Bullet] = []
var maximum_bullets: int = 1000

var audio_player_pool: Array[AudioStreamPlayer2D] = []
var maximum_audio_players: int = 300

func _ready():
	GameState.fire_bullet.connect(_on_fire_bullet)
	for i in range(maximum_bullets):
		var new_bullet = bullet_scene.instantiate()
		new_bullet.on_remove.connect(
			func():
				bullet_scene_pool.append(new_bullet))
		bullet_scene_pool.append(new_bullet)
		bullets_parent.call_deferred("add_child", new_bullet)
		
	for i in range(maximum_audio_players):
		var new_audio_player = AudioStreamPlayer2D.new()
		audio_player_pool.append(new_audio_player)
		new_audio_player.finished.connect(
			func():
				audio_player_pool.append(new_audio_player))
		audio_players_parent.call_deferred("add_child", new_audio_player)

# When a bullet is fired (by the player or an enemy) this function is "called". 
# We iterate over every bullet to be fired, instantiate them and point them at the player
# OR at where the player is clicking.
func _on_fire_bullet(origin, bullet_type: BulletResource, fire_from: FireFrom):
	play_audio(bullet_type.sound, fire_from.position)
	
	var layer_up: bool = false
	if origin.name == "angel_boss":
		layer_up = true
		
	if not (origin is WeakRef):
		origin = weakref(origin)
	
		
	
	# Iterate over every bullet that's being fired (the number of bullets to fire
	# is stored in .multishot)
	for index in range(bullet_type.multishot):
		var bullet = get_bullet()
		bullet.add_to_group("bullet")
		
		var start_position = fire_from.position
		var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
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
		bullet.set_data()
		bullet.z_index += 2 * int(layer_up)
		
		bullet.dead = false
		bullet.set_physics_process(true)
		bullet.show()
		if bullet.collision:
			bullet.collision.set_deferred("disabled", false)
		
func get_bullet() -> Bullet:
	GameState.bullets_summoned += 1
	GameState.player_data.total_bullets_summoned += 1
	GameState.num_bullets += 1
	if bullet_scene_pool.size() > 0:
		return bullet_scene_pool.pop_front()
	else:
		var new_bullet = bullet_scene.instantiate()
		new_bullet.on_remove.connect(
			func():
				bullet_scene_pool.append(new_bullet))
		bullets_parent.call_deferred("add_child", new_bullet)
		return new_bullet


func play_audio(sound, pos):
	var audio_player = get_audio_player()
	if audio_player == null:
		return
	audio_player.stream = sound
	audio_player.position = pos
	audio_player.bus = "SFX"
	audio_player.play()

func get_audio_player() -> AudioStreamPlayer2D:
	if audio_player_pool.size() > 0:
		return audio_player_pool.pop_front()
	else:
		return null
