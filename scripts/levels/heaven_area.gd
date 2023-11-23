extends Node


#var boss_area_scene := preload("res://scenes/levels/boss_area.tscn").instantiate()
#@export var hell_area_scene: PackedScene


@export var enemy_resource_list: Array[EnemyResource]

@export var bullet_handler: BulletHandler
@export var enemy_handler: EnemyHandler

@onready var HUD = $HUD

@onready var player: CharacterBody2D = GameState.player

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.current_area = GameState.CURRENT_AREA.HEAVEN
	GameState.current_area_node = self
	var player = $YSort/Player
	player.connect("level_up", _on_player_level_up)
	player.connect("player_death", _on_player_death)
	player.connect("hp_changed", HUD.show_health)
	player.connect("send_loadout", $LogicComponents/BossHandler._on_player_send_loadout)
	player.connect("credit_player", $LogicComponents/PickupHandler._on_pickup_credit_player)
	start_level()
	$YSort/teleporter.position = Vector2(GameState.player.position.x + 2, GameState.player.position.y - 10000)
	$ObjectiveMarker.add_target($YSort/teleporter)
	$LogicComponents/TerrainGenerator.generate()
	$LogicComponents/TerrainGenerator.cliff_generate()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_level():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	enemy_handler.start_spawning()
	
	player.position = $YSort/PlayerStart.position
	$LogicComponents/ShopHandler.start()
	$cursor_particles.emitting = true
	
	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(player.score, player.level_threshold[player.current_level])

func restart_game():
	GameState.load_area(GameState.CURRENT_AREA.HELL)

func _on_player_death():
	GameState.game_over.emit()

func _on_player_hp_changed(hp):
	HUD.show_health(hp, GameState.player.hp_max)


func _on_player_level_up(current_level):
	HUD.change_min_XP(player.level_threshold[player.current_level])
	HUD.show_health(player.hp, player.hp_max)
	enemy_handler.spawn_timer.wait_time /= 1.02
	enemy_handler.overall_multiplier += player.current_level / float(600)
	
