extends Node
class_name PickupHandler


@export var pickup_scene: PackedScene

@export var ysorter: Node2D
@export var score_display: CanvasLayer

var reward_pool
var xp_pools

@export var spawn_batch_size = 1
var spawn_queue: Array = []

func _ready():
	add_to_group("pickup_handler")
	GameState.register_enemy.connect(attach_enemy)
	reward_pool = Pool.new()
	reward_pool.populate([
		[Pickup.hp_pickup, 2],
		[Pickup.vacuum_pickup, 1],
		[Pickup.freeze_pickup, 1],
		[Pickup.fire_pickup, 1],
		[null, 150] # Default: 150
		])

func cleanup():
	spawn_queue = []

func _physics_process(_delta):
	if spawn_queue:
		for i in range(min(spawn_queue.size(), spawn_batch_size)):
			var data = spawn_queue.pop_back()
			really_spawn_pickup(data[0], data[1], data[2])

func attach_enemy(enemy):
	enemy.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(enemy):
	var value_remaining = enemy.value
	while value_remaining > 0:

		var value = maths(value_remaining, enemy.value)
		spawn_pickup(enemy.position, Pickup.xp_pickup, value)
		value_remaining -= value

	var sample = reward_pool.sample()
	if sample:
		spawn_pickup(enemy.position, sample)

func spawn_pickup(pos, type, value = 1):
	spawn_queue.append([pos,type,value])

func really_spawn_pickup(pos, type, value = 1):
	var pickup = pickup_scene.instantiate()
	pickup.position = pos
	pickup.pickup_type = type
	pickup.value = value

	ysorter.add_child(pickup)

func _on_pickup_credit_player(value):
	var player = GameState.player
	player.call_deferred("gain_score", value)
	if score_display:
		score_display.show_score(
			player.score,
			player.level_threshold
		)

func maths(value_remaining, enemy_value):
	if GameState.num_xp_pickups > 500:
		return value_remaining
	if enemy_value <= 10:
		return 1
	else:
		return randi_range(1,value_remaining)
