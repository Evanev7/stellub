extends Node2D

class_name AttackHandler


enum TARGET_MODE {PLAYER, MOUSE, NEAREST_ENEMY}
@export var target_mode = TARGET_MODE.PLAYER

var attack_direction: FireFrom = FireFrom.new()

func add_attack_from_resource(
		bullet: BulletResource,
		control_mode = Attack.CONTROL_MODE.PASSIVE,
		target: FireFrom = null
	) -> void:
	var attack = Attack.new()
	attack.name = bullet.name
	attack.initial_bullet = bullet
	attack.control_mode = control_mode
	if target:
		attack.aim_mode = Attack.AIM_MODE.FIXED
		attack.attack_direction = target
	else:
		attack.aim_mode = Attack.AIM_MODE.TARGETED
	
	add_child(attack)


func get_attack_direction() -> FireFrom:
	match target_mode:
		TARGET_MODE.MOUSE:
			attack_direction.toward(position + owner.position, get_global_mouse_position())
		TARGET_MODE.PLAYER:
			attack_direction.toward(position + owner.position, GameState.player.position)
		TARGET_MODE.NEAREST_ENEMY:
			#I can implement this if we think it's cool, I won't for now.
			pass
	
	return attack_direction


func stop() -> void:
	for attack in get_children():
		attack.timer_active = false

func start() -> void:
	for attack in get_children():
		attack.timer_active = true
