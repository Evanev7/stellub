extends Node

signal remove_marker_from_circle(circle)

@export var shop_scene: PackedScene
@export var magic_circle_scene: PackedScene

@export var default_shop_upgrades_list: Array[PackedScene]
@export var default_shop_weapons_list: Array[BulletResource]
var shop_upgrades_list: Array[PackedScene]
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
		#this is bad but needs fixing
		var upgrade_instance = upgrade.instantiate()
		upgrades.append([upgrade_instance, int(upgrade_instance.rarity*10)])
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
		chosen_upgrades = upgrade_pool.sample(3)
		is_weapon_present = true
		var weapon_node = Attack.new()
		weapon_node.initial_bullet = weapon_pool.sample(1)
		chosen_upgrades.append(weapon_node)
	else: 
		chosen_upgrades = upgrade_pool.sample(4)
	
	
	open_shop(chosen_upgrades, is_weapon_present, shop_attached_to)


func open_shop(stat_upgrades, is_weapon_present, shop_attached_to):
	GameState.pause_game()
	shop_node.shop_attached_to = shop_attached_to
	shop_node.set_visible(true)
	shop_node.open_shop(stat_upgrades, is_weapon_present)
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
