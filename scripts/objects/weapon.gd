extends Area2D

signal give_weapon_to_player(weapon)

@export var weapon: BulletResource

func _ready():
	add_to_group("weapon")
	print("spawned weapon")

func _on_body_entered(body):
	if body == GameState.player:
		give_weapon_to_player.emit(weapon)
	queue_free()
