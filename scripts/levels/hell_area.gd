extends Node


@export var heaven_area_scene: PackedScene

@export var enemy_resource_list: Array[EnemyResource]

@export var enemy_handler: EnemyHandler

@onready var HUD = $HUD

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game()
	$LogicComponents/ShopHandler.spawn_magic_circles()
	$LogicComponents/TerrainGenerator.generate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#print("bullets: " + str(get_tree().get_nodes_in_group("bullet").size()))
#	print("enemies: " + str(get_tree().get_nodes_in_group("enemy").size()))
	pass
	
	##Debug ###############################
	
	if GameState.debug and Input.is_action_pressed("debug_gain_score"): ## R
		GameState.player.gain_score(10)
		HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])
	
	if GameState.debug and Input.is_action_just_pressed("debug_evolve"): ## E
		GameState.player.current_evolution += 1
		GameState.player.evolve()
	
	if GameState.debug and Input.is_action_just_pressed("debug_spawn_enemy"): # L
		for i in range(10):
			$LogicComponents/EnemyHandler.spawn_enemy(randi() % 6)
		
	if GameState.debug and Input.is_action_just_pressed("debug_spawn_boss"): # B
		GameState.player.send_loadout_to_boss()
		
	if GameState.debug and Input.is_action_just_pressed("debug_activate_teleporter"): # T
		$LogicComponents/ShopHandler._on_activate_teleporter()
	#######################################


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	enemy_handler.start_spawning()
	GameState.player.start()
	GameState.player.position = $YSort/PlayerStart.position
	$LogicComponents/ShopHandler.start()
	start_magic_circles()
	
	HUD.show_message("All Hell Breaks Loose!")
	HUD.show_health(GameState.player.hp, GameState.player.hp_max)
	HUD.show_score(GameState.player.score, GameState.player.level_threshold[GameState.player.current_level])

func start_magic_circles():
	var circles = get_tree().get_nodes_in_group("magic_circle")
	for circle in circles:
		circle.start()

func _on_player_player_death():
	GameState.game_over.emit()


func _on_hud_start_game():
	start_game()


func _on_player_hp_changed(hp):
	HUD.show_health(hp, GameState.player.hp_max)


func _on_player_level_up(current_level):
	HUD.change_min_XP(GameState.player.level_threshold[GameState.player.current_level])
	HUD.show_health(GameState.player.hp, GameState.player.hp_max)
	GameState.player.current_level += 1
	GameState.player.souls += 1
	enemy_handler.spawn_timer.wait_time /= 1.02
	enemy_handler.overall_multiplier += GameState.player.current_level / float(400)
	

func teleport_to_heaven_area():
	var heaven_area_node = heaven_area_scene.instantiate()
	var player = GameState.player
	player.get_parent().remove_child(player)
	get_node("/root/Hell Area").queue_free()
	heaven_area_node.get_child(0).add_child(player)
	get_tree().root.add_child(heaven_area_node)




