extends Area2D

signal give_weapon_to_player(weapon)

@export var weapon: BulletResource

func _ready():
	add_to_group("weapon")
	
	
func _process(_delta):
	$SelfDestructHUD.value = $SelfDestruct.get_time_left()

func _on_body_entered(body):
	if body == GameState.player:
		give_weapon_to_player.emit(weapon)
		queue_free()


func _on_self_destruct_timeout():
	queue_free()
