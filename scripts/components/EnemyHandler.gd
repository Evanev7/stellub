extends Node 
class_name EnemyHandler

@onready var spawn_timer: Timer = $SpawnTimer
@onready var phase_up_timer: Timer = $PhaseUpTimer

@export var safe_range: float = 800
@export var default_spawn_time: float = 4.0
@export var overall_multiplier: float = 1.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]

@export var ysorter_enemies: Node2D
@export var bullet_handler: BulletHandler
@export var pickup_handler: PickupHandler

var phase_limit = 1

func _on_phase_up_timer_timeout():
	phase_limit += 1
	phase_limit = clamp(phase_limit, 1, enemy_resource_list.size() - 1)
	overall_multiplier += GameState.player.level_threshold[GameState.player.current_level] / 200
	spawn_enemy(phase_limit, GameState.player.position, safe_range, 1.5 * overall_multiplier)
	print(overall_multiplier)
	
	
func _on_spawn_timer_timeout():
	var resourceID = min(randi() % enemy_resource_list.size(), phase_limit)
	spawn_enemy(resourceID)
	
	
func spawn_enemy(resourceID, center = GameState.player.position, spawn_range = safe_range, unique_multiplier: float = 1):
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[resourceID]
	enemy.resource.UNIQUE_MULTIPLIER = unique_multiplier
	enemy.resource.OVERALL_MULTIPLIER = overall_multiplier
	var relative_spawn_position = Vector2(spawn_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = center + relative_spawn_position
	enemy.enemy_killed.connect(_on_enemy_killed)
	ysorter_enemies.add_child(enemy)
	
	
	
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
	phase_up_timer.stop()
