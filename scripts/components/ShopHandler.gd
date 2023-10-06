extends Node

@export var shop_scene: PackedScene
@export var magic_circle_scene: PackedScene

@export var default_shop_upgrades_list: Array[PackedScene]
var shop_upgrades_list: Array[PackedScene]

@export var enemyHandler: EnemyHandler
@export var ysorter: Node2D
@export var objective_marker: CanvasLayer
@export var upgrade_hud: CanvasLayer

func _ready():
	shop_upgrades_list = default_shop_upgrades_list.duplicate()

func spawn_magic_circles():
	var count = 10
	var radius = Vector2(1000, 0)
	var center = Vector2(0, 0)
	var step = 2 * PI / count
	
	for i in range(count):
		var spawn_pos = center + radius.rotated(step*i)
		var magic_circle = magic_circle_scene.instantiate()
		magic_circle.position = spawn_pos
		ysorter.add_child(magic_circle)
		objective_marker.add_target(magic_circle)
		magic_circle.connect("spawn_shop", _on_spawn_shop)
		magic_circle.connect("spawn_enemy_in_wave", _on_spawn_enemy_in_wave)


func _on_shop_entered():
	var chosen_upgrades = []
	var shop_array = shop_upgrades_list.duplicate()
	
	while chosen_upgrades.size() != 3:
		if shop_array.size() == 0:
			shop_array = shop_upgrades_list.duplicate()
			
		shop_array.shuffle()
		var upgrade = shop_array.pop_front().instantiate()

		if randf() <= upgrade.rarity:
			chosen_upgrades.append(upgrade)

	open_upgrade_hud(chosen_upgrades)


func open_upgrade_hud(stat_upgrades):
	get_tree().paused = true
	upgrade_hud.set_visible(true)
	upgrade_hud.show_HUD(stat_upgrades)


func _on_spawn_shop(position):
	var shop = shop_scene.instantiate()
	shop.show()
	shop.position = position
	ysorter.add_child(shop)
	shop.connect('shop_entered', _on_shop_entered)
	upgrade_hud.remove_shop.connect(shop._on_upgrade_hud_leave)


func _on_spawn_enemy_in_wave(resourceID, center, spawn_range):
	enemyHandler.spawn_enemy(resourceID, center, spawn_range)


func _on_upgrade_hud_remove_upgrade(upgrade):
	for i in shop_upgrades_list.size():
		if upgrade.scene_file_path == shop_upgrades_list[i].get_path():
			shop_upgrades_list.remove_at(i)
			break
