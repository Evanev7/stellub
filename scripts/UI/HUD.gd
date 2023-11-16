extends CanvasLayer

signal start_game
signal open_pause_menu

@onready var XP_Bar = $XPBar
@onready var HP_Bar = $HPBar
@onready var level = $XPBar/Level

func _ready():
	GameState.game_over.connect(game_over)

func _process(_delta):
	$FPS.set_text("FPS %d" % Engine.get_frames_per_second())
	level.set_text(str(GameState.player.current_level))

func show_message(text):
	$TextDisplay.text = text
	$TextDisplay.show()
	$DisplayTimer.start()


func _on_display_timer_timeout():
	$TextDisplay.hide() 


func _on_start_button_pressed():
	start_game.emit() 
	$StartButton.hide()
	XP_Bar.show()


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


func game_over():
	show_message("You suck!")
	await $DisplayTimer.timeout
	
	$TextDisplay.text = ""
	$TextDisplay.show()
	
	$StartButton.show()


func _on_pause_button_pressed():
	open_pause_menu.emit()
