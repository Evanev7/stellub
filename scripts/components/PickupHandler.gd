extends Node
class_name PickupHandler


@export var pickup_scene: PackedScene

@export var ysorter: Node2D
@export var score_display: CanvasLayer

var pool

func _ready():
	GameState.register_enemy.connect(attach_enemy)
	pool = Pool.new()
	pool.populate([[Pickup.hp_pickup,1], [Pickup.vacuum_pickup,1], [null,8]])

func attach_enemy(enemy):
	enemy.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(enemy):
	for i in range(enemy.value):
		spawn_pickup(enemy.position, Pickup.xp_pickup)
	
	var sample = pool.sample()
	if sample:
		spawn_pickup(enemy.position, sample)

func spawn_pickup(pos, type):
	var pickup = pickup_scene.instantiate()
	pickup.position = pos
	pickup.pickup_type = type

	ysorter.call_deferred("add_child", pickup)
	
func _on_pickup_credit_player(value):
	var player = GameState.player
	player.gain_score(value)
	if score_display:
		score_display.show_score(
			player.score,
			player.level_threshold[player.current_level]
		)

