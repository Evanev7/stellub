extends Node


@export var enemy_resource_list: Array[EnemyResource]

@export var enemy_handler: EnemyHandler

@onready var HUD = $HUD

@onready var player: CharacterBody2D = GameState.player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("level_up", _on_player_level_up)
	player.connect("player_death", _on_player_death)
	player.connect("show_freeze", HUD.freeze)
	player.connect("show_freeze", enemy_handler.freeze)
	player.connect("hp_changed", HUD.show_health)
	player.connect("credit_player", $LogicComponents/PickupHandler._on_pickup_credit_player)
	start_game()
	$YSort/teleporter.position = Vector2(GameState.player.position.x + randf_range(-100, 100), GameState.player.position.y - 20000) # 20000
	$YSort/teleporter.enabled()
	$YSort/teleporter.arrive_sound.play()
	$LogicComponents/TerrainGenerator.generate()
	$LogicComponents/TerrainGenerator.cliff_generate()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	enemy_handler.start_spawning()
	animate_entry()
	SoundManager.heaven_start_play()

	player.enable()
	player.position = $YSort/PlayerStart.position
	$LogicComponents/ShopHandler.start()
	$cursor_particles.emitting = true

	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(player.score, player.level_threshold[player.current_level])

	if GameState.player_data.first_time_heaven:
		HUD.show_dialogue("Hurry. You MUST make it to the tree.")
		GameState.player_data.first_time_heaven = false

func animate_entry():
	var tween: Tween = create_tween()
	tween.parallel().tween_property(HUD.get_node("VignetteTop"), "self_modulate", Color(1, 1, 1, 0), 3).from(Color(100, 100, 100, 1))
	tween.parallel().tween_property(player.camera_2d, "zoom", Vector2(1.2, 1.2), 0.5).\
	set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).from(Vector2(0.9, 0.9))

func restart_game():
	if SoundManager.currently_playing_music:
		SoundManager.currently_playing_music.stop()
	GameState.load_area(GameState.CURRENT_AREA.HELL)

func start_message():
	pass

func _on_player_death():
	GameState.queue_free_groups()
	enemy_handler.stop_spawning()

	if GameState.player_data.first_time == true:
		if SoundManager.currently_playing_music:
			SoundManager.fade_out(SoundManager.currently_playing_music)
		HUD.show_first_time()
	else:
		GameState.game_over.emit()
		if SoundManager.currently_playing_music:
			SoundManager.currently_playing_music.volume_db -= 10


func _on_player_hp_changed(hp):
	HUD.show_health(hp, GameState.player.hp_max)


func _on_player_level_up(_current_level):
	HUD.change_min_XP(player.level_threshold[player.current_level])
	HUD.show_health(player.hp, player.hp_max)
	enemy_handler.spawn_timer.wait_time /= 1.04
	enemy_handler.overall_multiplier += player.current_level / float(600)
