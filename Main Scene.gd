extends Node2D

var enemy_scene = preload("res://BasicEnemy.tscn")
const safe_range: int = 500
@onready var player = get_node("PlayerTopDown")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_timer_timeout():
	print("timer")
	var enemy = enemy_scene.instantiate()
	enemy.position = player.position + Vector2(safe_range, 0).rotated(randf_range(0, 2*PI))
	add_child(enemy)
