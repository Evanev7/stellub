extends Node

@export var pickup_scene: PackedScene

@export var ysorter: Node2D
@export var score_display: CanvasLayer

func spawn_pickup(pos):
	var pickup = pickup_scene.instantiate()
	pickup.credit_player.connect(_on_pickup_credit_player)
	pickup.position = pos
	ysorter.add_child(pickup)

func _on_pickup_credit_player(value):
	var player = GameState.player
	player.gain_score(value)
	if score_display:
		score_display.show_score(
			player.score,
			player.level_threshold[player.current_level]
		)
