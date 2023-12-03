extends Node

@export var enemy_resource_list: Array[EnemyResource]

#@export var enemy_handler: EnemyHandler

@onready var HUD = $HUD

@onready var player: CharacterBody2D = GameState.player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("level_up", _on_player_level_up)
	player.connect("player_death", _on_player_death)
	player.connect("hp_changed", HUD.show_health)
	#player.connect("credit_player", $LogicComponents/PickupHandler._on_pickup_credit_player)
	start_game()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	#enemy_handler.start_spawning()
	if SoundManager.currently_playing_music:
		SoundManager.fade_out(SoundManager.currently_playing_music)
	
	var tween: Tween = create_tween()
	tween.parallel().tween_property(HUD.get_node("VignetteTop"), "self_modulate", Color(1, 1, 1, 0), 2).from(Color(100, 100, 100, 1))
	tween.tween_property(player.get_node("Camera2D"), "zoom", Vector2(0.8, 0.8), 4).\
	set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	player.enable()
	player.position = $YSort/PlayerStart.position
	$cursor_particles.emitting = true
	
	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(player.score, player.level_threshold[player.current_level])

func restart_game():
	SoundManager.fade_out(SoundManager.currently_playing_music)
	GameState.load_area(GameState.CURRENT_AREA.HELL)
	
func start_message():
	pass

func _on_player_death():
	GameState.game_over.emit()
	SoundManager.currently_playing_music.volume_db = linear_to_db(0.5)

func _on_player_hp_changed(hp):
	HUD.show_health(hp, GameState.player.hp_max)


func _on_player_level_up(_current_level):
	HUD.change_min_XP(player.level_threshold[player.current_level])
	HUD.show_health(player.hp, player.hp_max)
#	enemy_handler.spawn_timer.wait_time /= 1.02
#	enemy_handler.overall_multiplier += player.current_level / float(600)
	
func heres_your_data(who):
	if who.name.to_lower() == "bossinit":
		var path = $IntroPath/PathFollow2D
		who.thanks_for_the_data(path)
