extends Node
class_name PickupHandler

@export var pickup_scene: PackedScene

@export var ysorter: Node2D
@export var score_display: CanvasLayer

#func _process(_delta):
#	print(get_tree().get_nodes_in_group("pickup").size())

func spawn_pickup(pos):
	var pickup = pickup_scene.instantiate()
	pickup.credit_player.connect(_on_pickup_credit_player)
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

