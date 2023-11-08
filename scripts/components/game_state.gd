extends Node

signal fire_bullet(origin, bullet: BulletResource, init: FireFrom)
signal game_over
signal register_enemy

var player: CharacterBody2D

var debug = true

func _ready():
	game_over.connect(queue_free_groups)

func pause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func unpause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false


func queue_free_groups():
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("boss", "queue_free")
	
	for circle in get_tree().get_nodes_in_group("magic_circle"):
		circle.call_deferred("remove_objective_marker", circle)
