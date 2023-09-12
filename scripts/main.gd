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

# When the spawn timer times out, spawn a new random enemy!
func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.resource = enemy_resource_list[randi() % enemy_resource_list.size()]
	var relative_spawn_position = Vector2(safe_range,0).rotated(randf_range(0, 2*PI))
	enemy.position = GameState.player.position + relative_spawn_position
	enemy.fire_bullet.connect(_on_fire_bullet)
	add_child(enemy)


# When a bullet is fired (by the player or an enemy) this function is "called". 
# We iterate over every bullet to be fired, instantiate them and point them at the player
# OR at where the player is clicking.
func _on_fire_bullet(origin, bullet_type: BulletResource):
	var inaccuracy_offset = randf_range(-bullet_type.shot_inaccuracy/2,bullet_type.shot_inaccuracy/2)
		
	# Iterate over every bullet that's being fired (the number of bullets to fire
	# is stored in .multishot)
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
		
		# The distance from the 'firer' that the bullet starts at.
		var start_range = Vector2(bullet_type.start_range, bullet_type.start_range)
		start_range *= target_direction
		
		bullet.set("direction", target_direction)
		bullet.set("data", bullet_type)
		bullet.set("origin_ref", weakref(origin))
		bullet.set("position", origin.position + start_range)
		bullet.set("scale", bullet_type.size)
		
		add_child(bullet)
	

func _on_start_timer_timeout():
	$SpawnTimer.start()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	$StartTimer.start()
	$Player.start($Marker2D.position)
	$SpawnTimer.set_wait_time(2.0)
	$HUD.show_message("All Hell Breaks Loose")
	$HUD.show_health(GameState.player.hp)
	$HUD.show_score(GameState.player.score)
	
#	create_spawn_timers()
#
#func create_spawn_timers():
#	var enemy = enemy_scene.instantiate()
#	for i in enemy_resource_list:
#		enemy.resource = i
#		var timer:= Timer.new()
#		add_child(timer)
#		timer.wait_time = enemy.resource.SPAWN_RATE
#		var func_name = "_on_" + enemy.resource.NAME + "_timeout"
#		print(func_name)
#		var callable = Callable(self, func_name)
#		timer.timeout.connect(callable.call())
#
#func _on_demon_skull_timeout() -> void:
#	print("demon_skull spawned")
#
#func _on_demon_dog_timeout() -> void:
#	print("demon_dog spawned")

func _on_player_player_death():
	game_over()
	
func game_over():
	$SpawnTimer.stop()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	$HUD.game_over()

func _on_hud_start_game():
	start_game()


func _on_player_taken_damage():
	$HUD.show_health(GameState.player.hp)


func _on_player_enemy_killed():
	$HUD.show_score(GameState.player.score)


func _on_player_level_up(current_level):
	open_upgrade_hud()
	$upgradeHUD.show_level(GameState.player.current_level)


func _on_upgrade_hud_upgrade_1_pressed():
	GameState.player.bullet.multishot += 1
	close_upgrade_hud()

func _on_upgrade_hud_upgrade_2_pressed():
	GameState.player.bullet.shot_spread /= 1.2
	close_upgrade_hud()

func _on_upgrade_hud_upgrade_3_pressed():
	GameState.player.bullet.fire_delay /= 1.2
	close_upgrade_hud()

func open_upgrade_hud():
	get_tree().paused = true
	$SpawnTimer.set_wait_time($SpawnTimer.get_wait_time() / 1.2)
	$upgradeHUD.set_visible(true)
	
func close_upgrade_hud():
	get_tree().paused = false
	$upgradeHUD.set_visible(false)
	var level = GameState.player.current_level
	if level % 3 == 0:
		GameState.player.current_animation = "level " + str(level/3)
	
