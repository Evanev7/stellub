extends Node

@export var enemy_scene: PackedScene
@export var bullet_scene: PackedScene
@export var safe_range: int = 500
var _firing: bool = false

@export var enemy_resource_list: Array[enemyResource]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_spawn_timer_timeout():
	print("spawned")
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[randi() % enemy_resource_list.size()]
	var spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + spawn_position
	add_child(enemy)

func _on_player_fire_bullet(number, spread, inaccuracy):
	var inaccuracy_offset = randf_range(-inaccuracy/2,inaccuracy/2)
	for index in range(number):
		var direction_offset
		if number > 1:
			direction_offset = inaccuracy_offset + remap(index, 0, number-1, -spread/2, spread/2)
		var bullet = bullet_scene.instantiate()
		var target_direction: Vector2
		var player = GameState.player
		target_direction = (player.get_global_mouse_position() - player.position).normalized()
		bullet.position = GameState.player.position
		if number > 1:
			bullet.direction = target_direction.rotated(direction_offset)
		else:
			bullet.direction = target_direction
		
		add_child(bullet)
	

func _on_start_timer_timeout():
	$SpawnTimer.start()
	
func start_game():
	$StartTimer.start()
	$Player.start($Marker2D.position)
	$Player.screen_size = $TextureRect.get_size()
	$SpawnTimer.set_wait_time(2.0)
	$HUD.show_message("All Hell Breaks Loose")
	$HUD.show_health(GameState.player.hp)
	$HUD.show_score(GameState.player.score)
	
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
	$HUD.show_health(GameState.player.hp)


func _on_player_enemy_killed():
	$HUD.show_score(GameState.player.score)

func _on_player_level_up(current_level):
	get_tree().paused = true
	$SpawnTimer.set_wait_time($SpawnTimer.get_wait_time() / 1.2)
	$upgradeHUD.set_visible(true)
	$upgradeHUD.show_level(GameState.player.current_level)

func _on_upgrade_hud_upgrade_1_pressed():
	GameState.player.multishot += 1
	get_tree().paused = false
	$upgradeHUD.set_visible(false)


func _on_upgrade_hud_upgrade_2_pressed():
	GameState.player.shot_spread /= 1.2
	get_tree().paused = false
	$upgradeHUD.set_visible(false)


func _on_upgrade_hud_upgrade_3_pressed():
	GameState.player.fire_delay /= 1.2
	get_tree().paused = false
	$upgradeHUD.set_visible(false)
