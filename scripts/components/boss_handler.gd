extends Node
class_name BossHandler

@export var boss_scene: PackedScene

@export var path_follow: PathFollow2D
@export var ysorter: Node2D

func spawn_boss():
	var boss = boss_scene.instantiate()
	ysorter.add_child(boss)

#func _physics_process(delta):
#	path_follow.progress += 100 * delta
