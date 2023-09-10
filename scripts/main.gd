extends Node

@export var enemy_scene: PackedScene
@export var bullet_scene: PackedScene
@export var safe_range: int = 500

@export var enemy_resource_list: Array[EnemyResource]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[randi() % enemy_resource_list.size()]
	var spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + spawn_position
	enemy.fire_bullet.connect(_on_fire_bullet)
	add_child(enemy)

func _on_fire_bullet(origin, bullet_type: BulletResource):
	var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
	for index in range(bullet_type.multishot):
		var bullet = bullet_scene.instantiate()
		var target_direction: Vector2
		var player = GameState.player
		if origin == player:
			target_direction = (player.get_global_mouse_position() - player.position).normalized()
		else:
			target_direction = (player.position - origin.position).normalized()
		
		var direction_offset = inaccuracy_offset
		if bullet_type.multishot > 1:
			direction_offset += remap(index, 0, bullet_type.multishot-1, -bullet_type.shot_spread/2, bullet_type.shot_spread/2)
		target_direction = target_direction.rotated(direction_offset)
		
		var start_range = Vector2(bullet_type.start_range, bullet_type.start_range)
		start_range *= target_direction
		
		bullet.set("direction", target_direction)
		bullet.set("data", bullet_type)
		bullet.set("origin", origin)
		bullet.set("position", origin.position + start_range)
		bullet.set("scale", bullet_type.size)
		
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
	pause_game()
	$upgradeHUD.show_level(GameState.player.current_level)

func _on_upgrade_hud_upgrade_1_pressed():
	GameState.player.bullet.multishot += 1
	unpause_game()


func _on_upgrade_hud_upgrade_2_pressed():
	GameState.player.bullet.shot_spread /= 1.2
	unpause_game()


func _on_upgrade_hud_upgrade_3_pressed():
	GameState.player.bullet.fire_delay /= 1.2
	unpause_game()

func pause_game():
	get_tree().paused = true
	$SpawnTimer.set_wait_time($SpawnTimer.get_wait_time() / 1.2)
	$upgradeHUD.set_visible(true)
	

func unpause_game():
	get_tree().paused = false
	$upgradeHUD.set_visible(false)
	
