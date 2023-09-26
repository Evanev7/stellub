extends Node
class_name PlayerAttack

@export var bullet: BulletResource

var _fire_timer = 0

func _physics_process(_delta):
	if bullet != null:
		_fire_timer += 1
		if _fire_timer > bullet.fire_delay:
			var fire_from = FireFrom.new()
			fire_from.toward(owner.position, owner.get_global_mouse_position())
			GameState.fire_bullet.emit(owner, bullet, fire_from)
			_fire_timer -= bullet.fire_delay
