extends Node

@export var enemy_scene: PackedScene
@export var bullet_scene: PackedScene
@export var safe_range: int = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	var spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + spawn_position
	
	add_child(enemy)

func _on_player_fire_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.position = GameState.player.position
	bullet.direction = (GameState.player.get_global_mouse_position() - bullet.position).normalized()
	
	add_child(bullet)
	

func _on_start_timer_timeout():
	$SpawnTimer.start()
	
func start_game():
	$StartTimer.start()
	$Player.start($Marker2D.position)
	$Player.screen_size = $TextureRect.get_size()
	$HUD.show_message("Begin")
	$HUD.show_val(GameState.player.hp)
	
func _on_player_player_death():
	game_over()
	
func game_over():
	$SpawnTimer.stop()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	$HUD.game_over()

func _on_hud_start_game():
	start_game() # Replace with function body.

	


func _on_player_taken_damage():
	$HUD.show_val(GameState.player.hp)
