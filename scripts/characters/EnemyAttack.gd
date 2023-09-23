extends Node
class_name Attack

@export var bullet: BulletResource

var _fire_timer

func _physics_process(_delta):
	var player_vector = GameState.player.position - owner.position
	if bullet != null:
		if player_vector.length() > bullet.deactivation_range:
			_fire_timer = 0
		else:
			_fire_timer += 1
			if _fire_timer > bullet.fire_delay:
				var fire_from = FireFrom.new()
				fire_from.toward(owner.position, GameState.player.position)
				GameState.fire_bullet.emit(owner, bullet, fire_from)
				_fire_timer -= bullet.fire_delay

