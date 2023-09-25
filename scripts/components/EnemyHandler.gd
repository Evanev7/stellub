extends Node 
class_name EnemyHandler

@onready var spawn_timer: Timer = $SpawnTimer
@onready var phase_up_timer: Timer = $PhaseUpTimer

@export var safe_range: float = 800
@export var default_spawn_time: float = 4.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]

@export var ysorter: Node2D
@export var bullet_handler: BulletHandler
@export var pickup_handler: PickupHandler

var phase_limit = 1

func _on_phase_up_timer_timeout():
	phase_limit += 1
	
	
func _on_spawn_timer_timeout():
	var resourceID = min(randi() % enemy_resource_list.size(), phase_limit)
	print("spawned " + str(resourceID))
	spawn_enemy(resourceID, GameState.player.position, safe_range)
	
	
func spawn_enemy(resourceID, center, spawn_range):
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[resourceID]
	var relative_spawn_position = Vector2(spawn_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = center + relative_spawn_position
	enemy.enemy_killed.connect(_on_enemy_killed)
	ysorter.add_child(enemy) # Replace with function body.
	
	
func _on_enemy_killed(enemy):
	for i in range(enemy.value):
		pickup_handler.spawn_pickup(enemy.position)
	
	
func start_spawning():
	phase_limit = 1
	spawn_timer.wait_time = default_spawn_time
	spawn_timer.start()
	phase_up_timer.start()
	
	
func stop_spawning():
	spawn_timer.stop()
