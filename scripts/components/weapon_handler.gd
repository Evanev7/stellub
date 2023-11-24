extends Node
class_name WeaponHandler

@export var weapon_scene: PackedScene
@export var weapon_resource_list: Array[BulletResource]

@export var ysorter: Node2D
@export var weapon_display: CanvasLayer

func spawn_weapon(pos):
	var weapon = weapon_scene.instantiate()
	weapon.give_weapon_to_player.connect(_on_weapon_pickup)
	weapon.position = pos
	ysorter.add_child(weapon)
	
func _on_weapon_pickup(weapon):
	GameState.player.add_attack_from_resource(weapon)
