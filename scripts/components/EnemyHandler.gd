extends Node 
class_name EnemyHandler

signal register_enemy(enemy)

@onready var spawn_timer: Timer = $SpawnTimer
@onready var phase_up_timer: Timer = $PhaseUpTimer

@export var safe_range: float = 800
@export var default_spawn_time: float = 4.0
@export var overall_multiplier: float = 1.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]

@export var enemy_ysort: Node2D

var phase_limit = 1

func _ready():
	GameState.game_over.connect(stop_spawning)

func _on_phase_up_timer_timeout():
	phase_limit += 1
	phase_limit = clamp(phase_limit, 1, enemy_resource_list.size() - 1)
	spawn_enemy(phase_limit, GameState.player.position, safe_range, 1.5, overall_multiplier)
	
	
func _on_spawn_timer_timeout():
	var resourceID = min(randi() % enemy_resource_list.size(), phase_limit)
	spawn_enemy(resourceID)
	
	
func spawn_enemy(resourceID, center = GameState.player.position, spawn_range = safe_range, unique_multiplier: float = 1, overall_multi = overall_multiplier):
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[resourceID]
	enemy.resource.UNIQUE_MULTIPLIER = unique_multiplier
	enemy.resource.OVERALL_MULTIPLIER = overall_multi
	var relative_spawn_position = Vector2(spawn_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = center + relative_spawn_position
	enemy_ysort.add_child(enemy)
	GameState.register_enemy.emit(enemy)
	
	
func start_spawning():
	phase_limit = 1
	spawn_timer.wait_time = default_spawn_time
	spawn_timer.start()
	phase_up_timer.start()
	
	
func stop_spawning():
	spawn_timer.stop()
	phase_up_timer.stop()
