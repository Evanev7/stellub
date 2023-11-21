extends Node

signal remove_marker_from_circle(circle)

@export var shop_scene: PackedScene
@export var magic_circle_scene: PackedScene
@export var attack_scene: PackedScene

@export var default_shop_upgrades_list: Array[UpgradeResource]
@export var default_shop_weapons_list: Array[BulletResource]
var shop_upgrades_list: Array[UpgradeResource]
var shop_weapons_list: Array[BulletResource]

@export var enemyHandler: EnemyHandler
@export var ysorter: Node2D
@export var objective_marker: CanvasLayer
@export var shop_node: CanvasLayer
@export var teleporter: Node2D

var upgrade_pool: Pool
var weapon_pool: Pool

func _ready():
	pass
	
	

func start():
	shop_upgrades_list = default_shop_upgrades_list.duplicate()
	shop_weapons_list = default_shop_weapons_list.duplicate()
	teleporter.start()
	
	upgrade_pool = Pool.new()
	weapon_pool = Pool.new()
	
	var upgrades = []
	for upgrade in shop_upgrades_list:
		upgrades.append([upgrade, upgrade.quantity])
	upgrade_pool.populate(upgrades)
	var weapons = []
	for weapon in shop_weapons_list:
		weapons.append([weapon, int(weapon.rarity*2)])
	weapon_pool.populate(weapons)
	

func spawn_magic_circles():
	var count = 10
	var radius = Vector2(3000, 0)
	var center = Vector2(0, 0)
	var step = 2 * PI / count
	
	for i in range(count):
		var spawn_pos = center + radius.rotated(step*i)
		var magic_circle = magic_circle_scene.instantiate()
		magic_circle.position = spawn_pos
		ysorter.add_child(magic_circle)
		objective_marker.add_target(magic_circle)
		magic_circle.connect("spawn_shop", _on_spawn_shop)
		magic_circle.connect("activate_teleporter", _on_activate_teleporter)
		magic_circle.connect("spawn_enemy_in_wave", _on_spawn_enemy_in_wave)
		magic_circle.connect("remove_circle_from_objective_marker", _on_remove_marker)


func _on_shop_entered(shop_attached_to):
	var chosen_upgrades = []
	var is_weapon_present := false
	
	if randf() <= 1:
		for upgrade in upgrade_pool.sample(3):
			var upgrade_node = upgrade_from_res(upgrade)
			chosen_upgrades.append(upgrade_node)
		is_weapon_present = true
		var weapon = weapon_pool.sample(1)
		var attack_node = attack_from_res(weapon)
		chosen_upgrades.append(attack_node)
	else: 
		for upgrade in upgrade_pool.sample(4):
			var upgrade_node = upgrade_from_res(upgrade)
			chosen_upgrades.append(upgrade_node)
	
	chosen_upgrades.shuffle()
	
	open_shop(chosen_upgrades, is_weapon_present, shop_attached_to)

func attack_from_res(bullet: BulletResource) -> Attack:
	var attack = attack_scene.instantiate()
	attack.name = bullet.name
	attack.initial_bullet = bullet
	attack.control_mode = Attack.CONTROL_MODE.PASSIVE
	attack.audio_player.stream = bullet.sound
	attack.aim_mode = Attack.AIM_MODE.TARGETED
	attack.icon = bullet.icon
	
	for i in range(GameState.player.current_level):
		attack.add_child(GameState.player.stat_upgrade.instantiate())
	
	return attack


func upgrade_from_res(upgrade_resource: UpgradeResource) -> Upgrade:
	var upgrade_node: Upgrade = upgrade_resource.upgrade_script.new()
	upgrade_node.script_data = upgrade_resource.script_data
	upgrade_node.skip = not upgrade_resource.appears_in_inventory
	upgrade_node.icon = upgrade_resource.icon
	upgrade_node.name = upgrade_resource.name
	upgrade_node.description = generate_description(upgrade_resource)
	return upgrade_node

func generate_description(upgrade_resource: UpgradeResource) -> String:
	var description: String = upgrade_resource.description
	var stats: String = """
	"""
	for key in upgrade_resource.script_data.keys():
		if key != "bullet":
			stats += "
			" + key + ": " + upgrade_resource.script_data[key] + "
			"
	description += stats
	return description 


func open_shop(chosen_upgrades, is_weapon_present, shop_attached_to):
	GameState.pause_game()
	shop_node.shop_attached_to = shop_attached_to
	shop_node.set_visible(true)
	shop_node.open_shop(chosen_upgrades, is_weapon_present)
	shop_node.connect('remove_shop', _remove_shop)

func _on_spawn_shop(position):
	var shop = shop_scene.instantiate()
	shop.show()
	shop.position = position
	ysorter.add_child(shop)
	shop.connect('shop_entered', _on_shop_entered)

func _remove_shop(shop):
	shop.queue_free()

func _on_activate_teleporter():
	teleporter.set_process(true)
	teleporter.enabled()
	
	
func _on_spawn_enemy_in_wave(resourceID, center, spawn_range):
	enemyHandler.spawn_enemy(resourceID, center, spawn_range)

func _on_remove_marker(circle):
	remove_marker_from_circle.emit(circle)

func _on_shop_remove_upgrade(upgrade):
	for i in shop_upgrades_list.size():
		if upgrade.scene_file_path == shop_upgrades_list[i].get_path():
			shop_upgrades_list.remove_at(i)
			break

func _on_shop_remove_weapon(weapon):
	for i in shop_weapons_list.size():
		if weapon.name == shop_weapons_list[i].name:
			shop_weapons_list.remove_at(i)
			break
