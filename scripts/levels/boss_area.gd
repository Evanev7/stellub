extends Node

@export var enemy_resource_list: Array[EnemyResource]

@onready var HUD = $HUD

@onready var player: CharacterBody2D = GameState.player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("level_up", _on_player_level_up)
	player.connect("player_death", _on_player_death)
	player.connect("hp_changed", HUD.show_health)
	#player.connect("credit_player", $LogicComponents/PickupHandler._on_pickup_credit_player)
	HUD.get_node("CircleCounter").hide()
	start_game()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():

	var tween: Tween = create_tween()
	tween.parallel().tween_property(HUD.get_node("VignetteTop"), "self_modulate", Color(1, 1, 1, 0), 2).from(Color(100, 100, 100, 1))
	tween.tween_property(player.camera_2d, "zoom", Vector2(0.6, 0.6), 3).\
	set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	player.enable()
	player.position = $YSort/PlayerStart.position
	$cursor_particles.emitting = true

	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(player.score, player.level_threshold)

	if GameState.player_data.first_time_boss:
		await get_tree().create_timer(2.0).timeout
		HUD.show_dialogue("Your...your runes, they...")
		await get_tree().create_timer(4.0).timeout
		HUD.show_dialogue("...they've been stolen?!")
		GameState.player_data.first_time_boss = false


func restart_game():
	if SoundManager.currently_playing_music:
		SoundManager.fade_out(SoundManager.currently_playing_music)
	GameState.load_area(GameState.CURRENT_AREA.HELL)

func start_message():
	pass

func _on_player_death():
	GameState.game_over.emit()
	GameState.queue_free_groups()

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
	HUD.change_min_XP(player.level_threshold)
	HUD.show_health(player.hp, player.hp_max)

func heres_your_data(who):
	if who.name.to_lower() == "bossinit":
		var path = $IntroPath/PathFollow2D
		who.thanks_for_the_data(path)
	elif who.name.to_lower() == "terrainattack":
		var ysort = $YSort
		var path = $TerrainAttackPath/PathFollow2D
		var centre = $YSort/BossCentre
		who.thanks_for_the_data(ysort, path, centre)
