extends CanvasLayer

signal start_game
signal open_pause_menu

func _ready():
	GameState.game_over.connect(game_over)

func _process(_delta):
	$FPS.set_text("FPS %d" % Engine.get_frames_per_second())

func show_message(text):
	$TextDisplay.text = text
	$TextDisplay.show()
	$DisplayTimer.start()


func _on_display_timer_timeout():
	$TextDisplay.hide() 


func _on_start_button_pressed():
	start_game.emit() 
	$StartButton.hide()
	$XPBar.show()


func show_health(number):
	$HealthDisplay.text = str(int(number))


func show_score(number, max_number):
	if number >= max_number:
		$XPBar.min_value = int(number)
	$XPBar.max_value = int(max_number)
	$XPBar.value = int(number)


func change_min_XP(number):
	$XPBar.min_value = int(number)


func game_over():
	show_message("You suck!")
	await $DisplayTimer.timeout
	
	$TextDisplay.text = ""
	$TextDisplay.show()
	
	$StartButton.show()


func _on_pause_button_pressed():
	print("paused")
	open_pause_menu.emit()
