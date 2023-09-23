extends Node

@export var shop_scene: PackedScene
@export var magic_circle_scene: PackedScene

@export var ysorter: Node2D
@export var objective_marker: CanvasLayer
@export var upgrade_hud: CanvasLayer

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
#		Removed this as we currently spawn a shop.
#		magic_circle.connect("shop_entered", _on_shop_entered)
		magic_circle.connect("spawn_shop", _on_spawn_shop)


func _on_shop_entered(stat_upgrades):
	open_upgrade_hud(stat_upgrades)


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
