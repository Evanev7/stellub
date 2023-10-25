extends Node
class_name BossHandler

@export var boss_scene: PackedScene

@export var path_follow: PathFollow2D
@export var ysorter: Node2D

func _on_player_send_loadout(loadout):
	var boss = boss_scene.instantiate()
	var boss_loadout = loadout.duplicate()
	boss.get_node("Enemy/AttackHandler").add_child(boss_loadout)
	ysorter.add_child(boss)
