extends Node2D

class_name AttackHandler

@export var attack_scene: PackedScene

var attack_direction: FireFrom = FireFrom.new()

func add_attack_from_resource(
		bullet: BulletResource,
		control_mode = Attack.CONTROL_MODE.PRIMARY,
		target: FireFrom = null
	) -> void:
	var attack = attack_scene.instantiate()
	attack.name = bullet.name
	attack.initial_bullet = bullet
	attack.control_mode = control_mode
	if target:
		attack.aim_mode = Attack.AIM_MODE.FIXED
		attack.attack_direction = target
	else:
		attack.aim_mode = Attack.AIM_MODE.TARGETED
	
	for i in range(GameState.player.current_level):
		var upgrade_node: Upgrade = GameState.player.stat_upgrade.upgrade_script.new()
		upgrade_node.script_data = GameState.player.stat_upgrade.script_data
		attack.add_child(upgrade_node)
		
	add_child(attack)


func get_attack_direction(target_mode) -> FireFrom:
	match target_mode:
		BulletResource.TARGET_MODE.MOUSE:
			attack_direction.toward(global_position, get_global_mouse_position())
		BulletResource.TARGET_MODE.PLAYER:
			attack_direction.toward(global_position, GameState.player.position)
		BulletResource.TARGET_MODE.NEAREST_ENEMY:
			var closest_enemy: Node = GameState.player
			var closest_enemy_distance: float = 0
			for enemy in get_tree().get_nodes_in_group("enemy"):
				var current_enemy_distance: float = owner.position.distance_to(enemy.global_position)
				if closest_enemy == GameState.player or current_enemy_distance < closest_enemy_distance:
					closest_enemy = enemy
					closest_enemy_distance = current_enemy_distance
			if closest_enemy_distance == 0:
				attack_direction.toward(global_position, get_global_mouse_position())
			else:
				attack_direction.toward(global_position, closest_enemy.position)
	
	return attack_direction


func upgrade_all_attacks(upgrade: UpgradeResource):
	for attack in get_children():
		var upgrade_node: Upgrade = upgrade.upgrade_script.new()
		upgrade_node.script_data = upgrade.script_data
		attack.add_child(upgrade_node)
		attack.refresh_bullet_resource()


func refresh_all_attacks():
	for attack in get_children():
		attack.refresh_bullet_resource()

func passive_all_attacks():
	for attack in get_children():
		attack.control_mode = Attack.CONTROL_MODE.PASSIVE
		
func aim_attacks_at_player():
	for attack in get_children():
		attack.initial_bullet.target_mode = BulletResource.TARGET_MODE.PLAYER


func stop() -> void:
	for attack in get_children():
		attack._timer = 20
		attack.timer_active = false

func clear_upgrades(attack) -> void:
	for upgrade in attack.get_children():
		attack.remove_child(upgrade)
	attack.refresh_bullet_resource()

func start() -> void:
	for attack in get_children():
		attack.timer_active = true
		attack._timer = 0.01
