extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)
signal spawn_enemy_in_wave(resource)

static var current_wave
var wave_active

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("magic_circle")
	current_wave = 1
	wave_active = false
	$WaveTimer.stop()
	$Time.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Time.text = str(int($WaveTimer.get_time_left() + 0.99))
	
	if wave_active:
		if is_equal_approx($SuccessTimer.get_time_left(), 10):
			spawn_enemies(2)
		elif is_equal_approx($SuccessTimer.get_time_left(), 20):
			spawn_enemies(1)


func _on_circle_body_entered(body):
	if body == GameState.player and not wave_active:
		$Time.show()
		$WaveTimer.start()


func _on_circle_body_exited(body):
	if body == GameState.player:
		$Time.hide()
		$WaveTimer.stop()


func _on_wave_timer_timeout():
	$Time.hide()
	wave_active = true
	$SuccessTimer.start()
	spawn_enemies(0)


func _on_success_timer_timeout():
	spawn_shop.emit(position)

#NOT WORKING
func spawn_enemies(timerValue):
	var skull = 0
	var dog = 1
	var skeleton = 2
	print(timerValue)
	if current_wave == 1:
		if timerValue == 0:
			for i in 5:
				spawn_enemy_in_wave.emit(skull)
		if timerValue == 1:
			for i in 5:
				spawn_enemy_in_wave.emit(skull)
		if timerValue == 2:
			for i in 5:
				spawn_enemy_in_wave.emit(dog)
				
	current_wave += 1

