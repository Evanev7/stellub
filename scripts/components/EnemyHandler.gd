extends Node

@onready var spawn_timer = $SpawnTimer

@export var safe_range: float = 1000
@export var default_spawn_time: float = 2.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]

@export var ysorter: Node2D
@export var bullet_handler: Node
@export var pickup_handler: Node


func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[randi() % enemy_resource_list.size()]
	var relative_spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + relative_spawn_position
	bullet_handler.add(enemy)
	enemy.enemy_killed.connect(_on_enemy_killed)
	add_child(enemy) # Replace with function body.

func _on_enemy_killed(enemy):
	for i in range(enemy.value):
		pickup_handler.spawn_pickup(enemy.position)

func start_spawning():
	spawn_timer.wait_time = default_spawn_time
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()
