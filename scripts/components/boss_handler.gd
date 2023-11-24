extends Node
class_name BossHandler

@export var boss_scene: PackedScene

@export var path_follow: PathFollow2D
@export var ysorter: Node2D

func _on_player_send_loadout(loadout):
	var boss = boss_scene.instantiate()
	var boss_loadout = loadout.duplicate()
	var freed_handler = boss.get_node("Enemy/AttackHandler")
	boss.get_node("Enemy/AttackHandler").replace_by(boss_loadout)
	freed_handler.queue_free()
	ysorter.add_child(boss)
