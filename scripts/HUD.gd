extends CanvasLayer

signal start_game
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func show_message(text):
	$TextDisplay.text = text
	$TextDisplay.show()
	$DisplayTimer.start()

func _on_display_timer_timeout():
	$TextDisplay.hide() # Replace with function body.


func _on_start_button_pressed():
	start_game.emit() # Replace with function body.
	$StartButton.hide()
	$XPBar.show()

func show_health(number):
	$HealthDisplay.text = str(number)

func show_score(number, max):
	if number >= max:
		$XPBar.min_value = int(number)
	$XPBar.max_value = int(max)
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
