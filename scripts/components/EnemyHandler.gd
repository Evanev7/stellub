extends Node 
class_name EnemyHandler

signal register_enemy(enemy)
signal spawn_shop_on_enemy(pos)

@onready var spawn_timer: Timer = $SpawnTimer
@onready var phase_up_timer: Timer = $PhaseUpTimer
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var damage_number_spawner = $DamageNumberSpawner


@export var safe_range: float = 800
@export var default_spawn_time: float = 4.08
@export var overall_multiplier: float = 1.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]
@export var damage_scene: PackedScene

@export var enemy_ysort: Node2D

var damage_scene_pool: Array[DamageNumber] = []
var maximum_damage_numbers: int = 300

var phase_limit = 1

func _ready():
	GameState.game_over.connect(stop_spawning)

func _on_phase_up_timer_timeout():
	if damage_scene_pool.size() > 1000:
		damage_scene_pool.resize(1000)
	phase_limit += 1
	phase_limit = clamp(phase_limit, 1, enemy_resource_list.size() - 1)
	spawn_enemy(phase_limit, GameState.player.position, safe_range, 3.5, overall_multiplier)


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
	enemy.connect("spawn_shop", spawn_shop)
	enemy.connect("play_damage_sound", play_damage_sound)
	enemy.connect("play_death_sound", play_death_sound)
	enemy.connect("spawn_damage_number", spawn_damage_number)
	enemy_ysort.add_child(enemy)
	GameState.register_enemy.emit(enemy)

func spawn_shop(pos):
	spawn_shop_on_enemy.emit(pos)

func spawn_damage_number(damage_value: float, position: Vector2, size: Vector2):
	var damage_number = get_damage_number()
	if not damage_number:
		return
	var val = damage_value
	damage_number.scale = size
	damage_number.set_values_and_animate(val, position, val * 20, 100 + 30 * val)

func get_damage_number() -> DamageNumber:
	if damage_scene_pool.size() > 0:
		return damage_scene_pool.pop_front()
	else:
		var new_damage_number = damage_scene.instantiate()
		new_damage_number.on_remove.connect(
			func():
				damage_scene_pool.append(new_damage_number))
		damage_number_spawner.add_child(new_damage_number, true)
		return new_damage_number

func play_damage_sound(pos):
	damage_sound.global_position = pos
	damage_sound.play()

func play_death_sound(pos):
	death_sound.global_position = pos
	death_sound.play()




func start_spawning():
	damage_scene_pool = []
	for i in range(maximum_damage_numbers):
		var new_damage_number = damage_scene.instantiate()
		new_damage_number.on_remove.connect(
			func():
				damage_scene_pool.append(new_damage_number))
		damage_scene_pool.append(new_damage_number)
		call_deferred("add_child", new_damage_number)
	phase_limit = 1
	spawn_timer.wait_time = default_spawn_time / (1.02 ** GameState.player.current_level)
	spawn_timer.start()
	phase_up_timer.start()

func stop_spawning():
	spawn_timer.stop()
	phase_up_timer.stop()
