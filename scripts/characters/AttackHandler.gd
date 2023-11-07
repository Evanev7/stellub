extends Node2D

class_name AttackHandler


enum TARGET_MODE {PLAYER, MOUSE, NEAREST_ENEMY}
@export var target_mode = TARGET_MODE.PLAYER

var attack_direction: FireFrom = FireFrom.new()

func add_attack_from_resource(
		bullet: BulletResource,
		control_mode = Attack.CONTROL_MODE.PRIMARY,
		target: FireFrom = null
	) -> void:
	var attack = Attack.new()
	attack.name = bullet.name
	attack.initial_bullet = bullet
	attack.control_mode = control_mode
	attack.audio_player = bullet.sound
	if target:
		attack.aim_mode = Attack.AIM_MODE.FIXED
		attack.attack_direction = target
	else:
		attack.aim_mode = Attack.AIM_MODE.TARGETED
	
	for i in range(GameState.player.current_level):
		attack.add_child(GameState.player.stat_upgrade.instantiate())
		
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


func upgrade_all_attacks(upgrade):
	for attack in get_children():
		var instantiated_upgrade = upgrade.instantiate()
		attack.add_child(instantiated_upgrade)
		attack.refresh_bullet_resource()
		


func passive_all_attacks():
	for attack in get_children():
		attack.control_mode = Attack.CONTROL_MODE.PASSIVE


func stop() -> void:
	for attack in get_children():
		attack.timer_active = false

func clear_upgrades(attack) -> void:
	for upgrade in attack.get_children():
		attack.remove_child(upgrade)
	attack.refresh_bullet_resource()

func start() -> void:
	for attack in get_children():
		attack.timer_active = true
