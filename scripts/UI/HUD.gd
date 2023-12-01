extends CanvasLayer

signal start_game
signal open_pause_menu
signal start_enemy_and_magic()

@onready var XP_Bar := $XPBar
@onready var HP_Bar := $HPBar
@onready var level := $XPBar/Level
@onready var vignette: TextureRect = $VignetteBottom
@onready var circle_counter: Control = $CircleCounter
@onready var main_text_container: TextureRect = $TextDisplay
@onready var main_text_display: Label = $TextDisplay/TextDisplay
@onready var dialogue_text_container: TextureRect = $DialogueDisplay
@onready var dialogue_text_display: Label = $DialogueDisplay/TextDisplay
@onready var tutorial: Node = $Tutorial

@onready var enemy_count = $Debug/EnemyCount
@onready var bullet_count = $Debug/BulletCount

#func _ready():
#	GameState.game_over.connect(game_over)

func _process(_delta):
	if GameState.fps_enabled:
		$FPS.visible = true
		$FPS.set_text("FPS %d" % Engine.get_frames_per_second())
	else:
		$FPS.visible = false
	level.set_text(str(GameState.player.current_level))

func reset_circle_counters():
	for sprite in circle_counter.get_children():
		sprite.play("off")

func show_message(text):
	main_text_display.text = text
	main_text_container.show()
	var tween: Tween = create_tween()
	tween.tween_property(main_text_container, "modulate:a", 1, 0.5)
	tween.tween_property(main_text_container, "modulate:a", 0, 2)
	$DisplayTimer.start()
	
func show_dialogue(text: String):
	dialogue_text_display.text = text
	dialogue_text_container.show()
	SoundManager.merchant_dialogue.play()
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_text_container, "modulate:a", 1, 0.5)
	tween.tween_callback($DisplayTimer.start)
	
	
	
func start_enemy_handler_and_magic_circles():
	start_enemy_and_magic.emit()
	
func show_first_time():
	$AudioStreamPlayer.play()
	var tween: Tween = create_tween()
	tween.tween_property($VignetteBottom, "self_modulate:a", 1, 5)
	main_text_display.text = "Alas. You have failed."
	tween.tween_property(main_text_container, "modulate:a", 1, 3)
	tween.tween_property(main_text_container, "modulate:a", 0, 2)
	tween.tween_property(main_text_display, "text", "I will keep waiting.", 0.1)
	tween.tween_property(main_text_container, "modulate:a", 1, 3)
	tween.tween_property(main_text_container, "modulate:a", 0, 2)
	tween.tween_property(main_text_display, "text", "For someone who can break through.", 0.1)
	tween.tween_property(main_text_container, "modulate:a", 1, 3)
	tween.tween_property(main_text_container, "modulate:a", 0, 2)
	tween.tween_callback(game_over)

func game_over():
	GameState.game_over.emit()
	main_text_container.modulate = Color(1, 1, 1, 0)
	$VignetteBottom.modulate = Color(1, 1, 1, 0)
	

func _on_display_timer_timeout():
	main_text_container.hide()
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_text_container, "modulate:a", 0, 1)
	tween.tween_callback(dialogue_text_container.hide)
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
	bullet_count.text = "bullets: " + str(GameState.num_bullets)
	enemy_count.text = "enemies: " + str(get_tree().get_nodes_in_group("enemy").size())
	$DisplayTimer.start()


func _on_shop_handler_activate_circle(circle):
	var circle_to_turn_on = "Circle" + str(circle)
	circle_counter.get_node(circle_to_turn_on).play("on")
