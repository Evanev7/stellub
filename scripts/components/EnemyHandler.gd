extends Node 
class_name EnemyHandler

signal register_enemy(enemy)
signal spawn_shop_on_enemy(pos)

@onready var spawn_timer: Timer = $SpawnTimer
@onready var phase_up_timer: Timer = $PhaseUpTimer
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var damage_number_spawner = $DamageNumberSpawner

@export var spawn_batch_size = 1
var spawn_queue: Array = []

@export var safe_range: float = 800
@export var default_spawn_time: float = 2.08
@export var overall_multiplier: float = 1.0

@export var enemy_scene: PackedScene
@export var enemy_resource_list: Array[EnemyResource]
@export var damage_scene: PackedScene

@export var enemy_ysort: Node2D

var damage_scene_pool: Array[DamageNumber] = []
var maximum_damage_numbers: int = 300

var enemy_rarity_pool: Pool
var enemy_scene_pool: Array[EnemyBehaviour] = []
var maximum_enemies: int = 800

@onready var phase_limit = 1

func _ready():
	GameState.game_over.connect(stop_spawning)
	
	enemy_rarity_pool = Pool.new()
	
	var enemies = []
	for i in range(2):
		enemies.append([i, enemy_resource_list[i].QUANTITY])
	enemy_rarity_pool.populate(enemies)
	
	for i in range(maximum_damage_numbers):
		var new_damage_number = damage_scene.instantiate()
		new_damage_number.on_remove.connect(
			func():
				damage_scene_pool.append(new_damage_number))
		damage_scene_pool.append(new_damage_number)
		call_deferred("add_child", new_damage_number)

func _physics_process(_delta):
	if spawn_queue:
		for i in range(min(spawn_queue.size(), spawn_batch_size)):
			var data = spawn_queue.pop_back()
			really_spawn_enemy(data[0], data[1], data[2], data[3], data[4])

func _on_phase_up_timer_timeout():
	if damage_scene_pool.size() > 1000:
		damage_scene_pool.resize(1000)
	phase_limit += 1
	phase_limit = clamp(phase_limit, 1, enemy_resource_list.size() - 1)
	
	var new_enemy = []
	new_enemy.append([phase_limit, enemy_resource_list[phase_limit].QUANTITY])
	enemy_rarity_pool.populate(new_enemy)
	
	spawn_enemy(phase_limit, GameState.player.position, safe_range, 3.5, overall_multiplier)


func _on_spawn_timer_timeout():
	var resourceID = enemy_rarity_pool.sample()
	
	spawn_enemy(resourceID)
	
	if GameState.current_area == GameState.CURRENT_AREA.HEAVEN:
		spawn_timer.wait_time /= 1.008


func spawn_enemy(resourceID, centre = GameState.player.position, spawn_range = safe_range, unique_multiplier: float = 1, overall_multi = overall_multiplier):
	spawn_queue.push_front([resourceID, centre, spawn_range, unique_multiplier, overall_multi])

func really_spawn_enemy(resourceID, centre = GameState.player.position, spawn_range = safe_range, unique_multiplier: float = 1, overall_multi = overall_multiplier):
	var enemy = get_enemy()
	GameState.num_enemies += 1
	enemy.resource = enemy_resource_list[resourceID]
	enemy.resource.UNIQUE_MULTIPLIER = unique_multiplier
	enemy.resource.OVERALL_MULTIPLIER = overall_multi
	var relative_spawn_position: Vector2
	if GameState.current_area == GameState.CURRENT_AREA.HEAVEN:
		relative_spawn_position = Vector2(spawn_range,0).rotated(randf_range(-PI, 0))
	else:
		relative_spawn_position = Vector2(spawn_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = centre + relative_spawn_position
	
	enemy.dead = false
	enemy.set_physics_process(true)
	enemy.sprite.visible = true
	enemy.shadow.visible = true
	enemy.set_data()
	enemy.collider.set_deferred("disabled", false)
	enemy.hitbox_collisionshape.set_deferred("disabled", false)
	enemy.hurtbox_collisionshape.set_deferred("disabled", false)
	
	
	
func get_enemy():
	if enemy_scene_pool.size() > 0:
		return enemy_scene_pool.pop_front()
	else:
		var new_enemy = enemy_scene.instantiate()
		new_enemy.on_remove.connect(
			func():
				enemy_scene_pool.append(new_enemy))
		connect_enemy(new_enemy)
		enemy_ysort.call_deferred("add_child", new_enemy)
		return new_enemy

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
	enemy_scene_pool = []
	
		
	for i in range(maximum_enemies):
		var new_enemy = enemy_scene.instantiate()
		new_enemy.on_remove.connect(
			func():
				enemy_scene_pool.append(new_enemy))
		enemy_scene_pool.append(new_enemy)
		connect_enemy(new_enemy)
		enemy_ysort.call_deferred("add_child", new_enemy)
		
	phase_limit = 1
	spawn_timer.wait_time = default_spawn_time / ((1.02 * (GameState.current_area + 1)) ** GameState.player.current_level)
	overall_multiplier = 1 + (GameState.player.current_level / float(600)) * GameState.player.current_level
	spawn_timer.start()
	phase_up_timer.start()
	
func connect_enemy(enemy):
	enemy.connect("spawn_shop", spawn_shop)
	enemy.connect("play_damage_sound", play_damage_sound)
	enemy.connect("play_death_sound", play_death_sound)
	enemy.connect("spawn_damage_number", spawn_damage_number)
	GameState.register_enemy.emit(enemy)

func stop_spawning():
	spawn_timer.stop()
	phase_up_timer.stop()
