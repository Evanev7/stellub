extends CanvasLayer

signal start_game


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
	$HealthDisplay.text = str(number)


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
	
	$TextDisplay.text = "Main Menu"
	$TextDisplay.show()
	$GameOverTimer.start()
	
	await $GameOverTimer.timeout
	
	$StartButton.show()