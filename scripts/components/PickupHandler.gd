extends Node
class_name PickupHandler

@export var pickup_scene: PackedScene

@export var ysorter: Node2D
@export var score_display: CanvasLayer

func _ready():
	GameState.register_enemy.connect(attach_enemy)

func attach_enemy(enemy):
	enemy.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(enemy):
	for i in range(enemy.value):
		spawn_pickup(enemy.position)

func spawn_pickup(pos):
	var pickup = pickup_scene.instantiate()
	pickup.position = pos
	ysorter.call_deferred("add_child", pickup)
	
func _on_pickup_credit_player(value):
	var player = GameState.player
	player.gain_score(value)
	if score_display:
		score_display.show_score(
			player.score,
			player.level_threshold[player.current_level]
		)

