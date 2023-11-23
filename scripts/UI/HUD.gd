extends CanvasLayer

signal start_game
signal open_pause_menu

@onready var XP_Bar = $XPBar
@onready var HP_Bar = $HPBar
@onready var level = $XPBar/Level

@onready var enemy_count = $Debug/EnemyCount
@onready var bullet_count = $Debug/BulletCount

#func _ready():
#	GameState.game_over.connect(game_over)

func _process(_delta):
	$FPS.set_text("FPS %d" % Engine.get_frames_per_second())
	level.set_text(str(GameState.player.current_level))

func show_message(text):
	$TextDisplay.text = text
	$TextDisplay.show()
	$TextDisplay.modulate = Color(1, 1, 1, 1)
	var tween: Tween = create_tween()
	tween.tween_property($TextDisplay, "modulate:a", 0, 2)
	$DisplayTimer.start()

func show_first_time():
	$AudioStreamPlayer.play()
	var tween: Tween = create_tween()
	tween.tween_property($TextureRect, "self_modulate:a", 1, 5)
	$TextDisplay/TextDisplay.text = "Alas. You have failed."
	tween.tween_property($TextDisplay, "modulate:a", 1, 3)
	tween.tween_property($TextDisplay, "modulate:a", 0, 2)
	tween.tween_property($TextDisplay/TextDisplay, "text", "I will keep waiting.", 0.1)
	tween.tween_property($TextDisplay, "modulate:a", 1, 3)
	tween.tween_property($TextDisplay, "modulate:a", 0, 2)
	tween.tween_property($TextDisplay/TextDisplay, "text", "For someone who can break through.", 0.1)
	tween.tween_property($TextDisplay, "modulate:a", 1, 3)
	tween.tween_property($TextDisplay, "modulate:a", 0, 2)
	tween.tween_callback(game_over)

func game_over():
	GameState.game_over.emit()
	$TextDisplay.modulate = Color(1, 1, 1, 0)
	$TextureRect.modulate = Color(1, 1, 1, 0)
	

func _on_display_timer_timeout():
	$TextDisplay.hide()
	$Debug.hide()


func show_health(number, max_number):
	HP_Bar.max_value = int(max_number)
	HP_Bar.value = int(number)


func show_score(number, max_number):
	if number >= max_number:
		XP_Bar.min_value = int(number)
	XP_Bar.max_value = int(max_number)
	XP_Bar.value = int(number)


func change_min_XP(number):
	XP_Bar.min_value = int(number)


func _on_pause_button_pressed():
	open_pause_menu.emit()


func show_debug():
	$Debug.show()
	bullet_count.text = "bullets: " + str(get_tree().get_nodes_in_group("bullet").size())
	enemy_count.text = "enemies: " + str(get_tree().get_nodes_in_group("enemy").size())
	$DisplayTimer.start()
