extends Node

@export var enemy_scene: PackedScene
@export var bullet_scene: PackedScene
@export var pickup_scene: PackedScene
@export var safe_range: int = 500

@export var enemy_resource_list: Array[EnemyResource]



# Called when the node enters the scene tree for the first time.
func _ready():
	$YSort/TerrainGenerator.generate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass
	##Debug ###############################
	
	if Input.is_key_pressed(KEY_R): ## Increase score by 10
		GameState.player.gain_score(10)
		$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])
	
	#######################################

# When the spawn timer times out, spawn a new random enemy!
func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[randi() % enemy_resource_list.size()]
	var relative_spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + relative_spawn_position
	enemy.fire_bullet.connect(_on_fire_bullet)
	enemy.enemy_killed.connect(_on_enemy_killed)
	$YSort.add_child(enemy)


# When a bullet is fired (by the player or an enemy) this function is "called". 
# We iterate over every bullet to be fired, instantiate them and point them at the player
# OR at where the player is clicking.
func _on_fire_bullet(origin, bullet_type: BulletResource, fire_from: FireFrom):
	if not (origin is WeakRef):
		origin = weakref(origin)
	var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
		
	# Iterate over every bullet that's being fired (the number of bullets to fire
	# is stored in .multishot)
	for index in range(bullet_type.multishot):
		var bullet = bullet_scene.instantiate()
		bullet.fire_bullet.connect(_on_fire_bullet)
		
		var start_position = fire_from.position
		
		var direction_offset = inaccuracy_offset
		if bullet_type.multishot > 1:
			direction_offset += remap(index, 0, bullet_type.multishot-1, -bullet_type.shot_spread/2, bullet_type.shot_spread/2)
		var start_direction = fire_from.direction.rotated(direction_offset)
		
		# The distance from the 'firer' that the bullet starts at.
		var start_range = Vector2(bullet_type.start_range, bullet_type.start_range)
		start_range *= start_direction
		start_position += start_range
		
		bullet.direction = start_direction
		bullet.data = bullet_type
		bullet.origin_ref = origin
		bullet.position = start_position
		
		call_deferred("add_child",bullet)
		

func _on_start_timer_timeout():
	$SpawnTimer.start()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	$StartTimer.start()
	GameState.player.start()
	$SpawnTimer.set_wait_time(2.0)
	$HUD.show_message("All Hell Breaks Loose")
	$HUD.show_health(GameState.player.hp)
	$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])
	spawn_shop()
	
	
func spawn_shop():
	$YSort/Shop.set_process(true)
	#$YSort/Shop.position = Vector2($YSort/Shop.position.x, GameState.player.position.y - 000)
	
func _on_shop_shop_entered(stat_upgrades):
	$YSort/Shop.shop_entries += 1
	print($YSort/Shop.shop_entries)
	print($YSort/Shop.shop_limit)
	open_upgrade_hud(stat_upgrades)


func _on_player_player_death():
	game_over()
	
func game_over():
	$SpawnTimer.stop()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	$HUD.game_over()

func _on_hud_start_game():
	start_game()


func _on_player_taken_damage(hp):
	$HUD.show_health(hp)


func _on_enemy_killed(enemy):
	for i in range(enemy.value):
		spawn_pickup(enemy.position)


func spawn_pickup(pos):
	var pickup = pickup_scene.instantiate()
	pickup.credit_player.connect(_on_pickup_credit_player)
	pickup.position = pos
	$YSort.add_child(pickup)

func _on_pickup_credit_player(value):
	GameState.player.gain_score(value)
	$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])

func _on_player_level_up(current_level):
	$HUD.change_min_XP(GameState.player.level_threshold[GameState.player.current_level])
	GameState.player.current_level += 1
	GameState.player.souls += 1
	$SpawnTimer.set_wait_time($SpawnTimer.get_wait_time() / 1.2)


func _on_upgrade_hud_upgrade_1_pressed(stat):
	GameState.player.stat_upgrade(stat)
	close_upgrade_hud()

func _on_upgrade_hud_upgrade_2_pressed(stat):
	GameState.player.stat_upgrade(stat)
	close_upgrade_hud()

func _on_upgrade_hud_upgrade_3_pressed(stat):
	GameState.player.stat_upgrade(stat)
	close_upgrade_hud()

func open_upgrade_hud(stat_upgrades):
	get_tree().paused = true
	$upgradeHUD.set_visible(true)
	$upgradeHUD.show_HUD(stat_upgrades)
	
func close_upgrade_hud():
	get_tree().paused = false
	$upgradeHUD.set_visible(false)
	if $YSort/Shop.shop_entries >= $YSort/Shop.shop_limit:
		$YSort/Shop.disable()
		$ObjectiveMarker.arrow_target = null
	else:
		$YSort/Shop.move_shop()
		
	GameState.player.evolve()


