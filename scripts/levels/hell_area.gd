extends Node


#@export var heaven_area_scene: PackedScene

@export var enemy_resource_list: Array[EnemyResource]

@export var enemy_handler: EnemyHandler

@onready var HUD = $HUD

@onready var player: CharacterBody2D = GameState.player

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game()
	
	if GameState.first_time == false:
		start_message()
	
	$LogicComponents/TerrainGenerator.generate()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	$LogicComponents/ShopHandler.spawn_magic_circles()
	player.start()
	enemy_handler.start_spawning()
	player.position = $YSort/PlayerStart.position
	$LogicComponents/ShopHandler.start()
	$cursor_particles.emitting = true
	start_magic_circles()
	
	HUD.reset_circle_counters()	
	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(0, 10)

func start_message():
	HUD.show_message("The TREE beckons once more.")

func start_magic_circles():
	var circles = get_tree().get_nodes_in_group("magic_circle")
	for circle in circles:
		circle.start()

func _on_player_player_death():
	GameState.queue_free_groups()
	enemy_handler.stop_spawning()
	
	for magic_circle in get_tree().get_nodes_in_group("magic_circle"):
		magic_circle.remove_objective_marker()
	
	if GameState.first_time == true:
		HUD.show_first_time()
	else:
		GameState.game_over.emit()
	
func on_restart_game():
	start_game()
	

func _on_player_hp_changed(hp):
	HUD.show_health(hp, player.hp_max)


func _on_player_level_up(current_level):
	HUD.change_min_XP(player.level_threshold[player.current_level])
	HUD.show_health(player.hp, player.hp_max)
	enemy_handler.spawn_timer.wait_time /= 1.02
	enemy_handler.overall_multiplier += player.current_level / float(600)



