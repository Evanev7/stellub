extends Node


@export var magic_circle_scene: PackedScene
@export var pickup_scene: PackedScene
@export var safe_range: int = 500

@export var enemy_resource_list: Array[EnemyResource]

@export var bullet_handler: Node
@export var enemy_handler: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_magic_circles()
	$YSort/TerrainGenerator.generate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass
	##Debug ###############################
	
	if Input.is_key_pressed(KEY_R): ## Increase score by 10
		GameState.player.gain_score(10)
		$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])
	
	#######################################


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	enemy_handler.start_spawning()
	GameState.player.start()
	GameState.player.position = $YSort/Marker2D.position
	$HUD.show_message("All Hell Breaks Loose!")
	$HUD.show_health(GameState.player.hp)
	$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])


func spawn_magic_circles():
	var count = 10
	var radius = Vector2(1000, 0)
	var center = Vector2(0, 0)
	var step = 2 * PI / count
	
	for i in range(count):
		var spawn_pos = center + radius.rotated(step*i)
		var magic_circle = magic_circle_scene.instantiate()
		magic_circle.position = spawn_pos
		add_child(magic_circle)
		$ObjectiveMarker.add_target(magic_circle)
		magic_circle.connect("shop_entered", _on_shop_entered)


func _on_shop_entered(stat_upgrades):
	open_upgrade_hud(stat_upgrades)


func _on_player_player_death():
	game_over()


func game_over():
	enemy_handler.stop_spawning()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	
	var magic_circles = get_tree().get_nodes_in_group("magic_circle")
	for magic_circle in magic_circles:
		$ObjectiveMarker.delete_target(magic_circle)
		magic_circle.queue_free()
		
	$HUD.game_over()


func _on_hud_start_game():
	start_game()


func _on_player_taken_damage(hp):
	$HUD.show_health(hp)


func _on_player_level_up(current_level):
	$HUD.change_min_XP(GameState.player.level_threshold[GameState.player.current_level])
	GameState.player.current_level += 1
	GameState.player.souls += 1
	enemy_handler.spawn_timer.wait_time /= 1.02


func open_upgrade_hud(stat_upgrades):
	get_tree().paused = true
	$upgradeHUD.set_visible(true)
	$upgradeHUD.show_HUD(stat_upgrades)

