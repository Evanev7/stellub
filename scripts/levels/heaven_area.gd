extends Node


#var boss_area_scene := preload("res://scenes/levels/boss_area.tscn").instantiate()


@export var enemy_resource_list: Array[EnemyResource]

@export var bullet_handler: BulletHandler
@export var enemy_handler: EnemyHandler

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = $YSort/Player
	player.connect("level_up", _on_player_level_up)
	player.connect("player_death", _on_player_death)
	player.connect("hp_changed", _on_player_hp_changed)
	player.connect("send_loadout", $LogicComponents/BossHandler._on_player_send_loadout)
	player.connect("credit_player", $LogicComponents/PickupHandler._on_pickup_credit_player)
	start_level()
	#$LogicComponents/ShopHandler.spawn_magic_circles()
	$LogicComponents/TerrainGenerator.generate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	randomize()
	#print("bullets: " + str(get_tree().get_nodes_in_group("bullet").size()))
	pass
	
	##Debug ###############################
	
	if GameState.debug and Input.is_action_pressed("debug_gain_score"): ## Increase score by 10
		GameState.player.gain_score(10)
		$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])
	
	if GameState.debug and Input.is_action_just_pressed("debug_evolve"): ## Increase evolution by 1
		GameState.player.current_evolution += 1
		GameState.player.evolve()
	
	if GameState.debug and Input.is_action_just_pressed("debug_spawn_enemy"):
		$LogicComponents/EnemyHandler.spawn_enemy(randi() % 4)
		
	if GameState.debug and Input.is_action_just_pressed("debug_spawn_boss"):
		GameState.player.send_loadout_to_boss()
	#######################################


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_level():
	enemy_handler.start_spawning()
	GameState.player.position = $YSort/PlayerStart.position
	#$LogicComponents/ShopHandler.start()
	#start_magic_circles()
	
	$HUD.show_message("All Hell Breaks Loose!")
	$HUD.show_health(GameState.player.hp)
	$HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])

#func start_magic_circles():
#	var circles = get_tree().get_nodes_in_group("magic_circle")
#	for circle in circles:
#		circle.start()

func _on_player_death():
	game_over()


func game_over():
	enemy_handler.stop_spawning()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("boss", "queue_free")
	
	$HUD.game_over()


#func _on_hud_start_game():
#	start_level()


func _on_player_hp_changed(hp):
	$HUD.show_health(hp)


func _on_player_level_up(current_level):
	$HUD.change_min_XP(GameState.player.level_threshold[GameState.player.current_level])
	$HUD.show_health(GameState.player.hp)
	GameState.player.current_level += 1
	GameState.player.souls += 1
	enemy_handler.spawn_timer.wait_time /= 1.02
	

#func teleport_to_boss_area():
#	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(heaven_area_scene))
	