extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)
signal spawn_enemy_in_wave(resource)

static var current_circle: int = 1
var wave_active: bool = false

var first_wave: bool = false
var second_wave: bool = false
var third_wave: bool = false
var fourth_wave: bool = false
var fifth_wave: bool = false
var sixth_wave: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("magic_circle")

func start():
	get_node("Circle/CollisionShape2D").disabled = false
	current_circle = 1
	wave_active = false
	$WaveTimer.stop()
	$Time.hide()
	$SuccessTimer.wait_time = 30
	reset_bools()
	
func reset_bools():
	first_wave = false
	second_wave = false
	third_wave = false
	fourth_wave = false
	fifth_wave = false
	sixth_wave = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Time.text = str(int($WaveTimer.get_time_left() + 0.99))
	
	if wave_active:
		$Time.text = str(int($SuccessTimer.get_time_left()))
		if $SuccessTimer.get_time_left() < 10:
			spawn_enemies(1)
		if $SuccessTimer.get_time_left() < 20:
			spawn_enemies(2)
		if $SuccessTimer.get_time_left() < 30:
			spawn_enemies(3)
		if $SuccessTimer.get_time_left() < 40:
			spawn_enemies(4)
		if $SuccessTimer.get_time_left() < 50:
			spawn_enemies(5)
		if $SuccessTimer.get_time_left() < 60:
			spawn_enemies(6)


func _on_circle_body_entered(body):
	if body == GameState.player and not wave_active:
		$Time.show()
		$WaveTimer.start()


func _on_circle_body_exited(body):
	if body == GameState.player:
		if not wave_active:
			$Time.hide()
		$WaveTimer.stop()


func _on_wave_timer_timeout():
	wave_active = true
	$SuccessTimer.wait_time = 20 + (10 * current_circle)
	$SuccessTimer.start()
	spawn_enemies(0)


func _on_success_timer_timeout():
	spawn_shop.emit(position)
	reset_bools()
	wave_active = false
	$Time.hide()
	current_circle += 1
	get_node("Circle/CollisionShape2D").disabled = true


func spawn_enemies(timerValue):
	var skull = 0
	var dog = 1
	var skeleton = 2
	if current_circle == 1:
		if timerValue == 0:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
		if timerValue == 2 and first_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
			first_wave = true
		if timerValue == 1 and second_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(dog, position, 500)
			second_wave = true
			
	if current_circle == 2:
		if timerValue == 0:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
		if timerValue == 3 and first_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
			first_wave = true
		if timerValue == 2 and second_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(dog, position, 500)
			second_wave = true
		if timerValue == 1 and third_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skeleton, position, 500)
			third_wave = true
			
	if current_circle == 3:
		if timerValue == 0:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
		if timerValue == 4 and first_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
			first_wave = true
		if timerValue == 3 and second_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(dog, position, 500)
			second_wave = true
		if timerValue == 2 and third_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skeleton, position, 500)
			third_wave = true
		if timerValue == 1 and fourth_wave == false:
			for i in 7:
				spawn_enemy_in_wave.emit(skeleton, position, 600)
			fourth_wave = true
			
	if current_circle == 4:
		if timerValue == 0:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
		if timerValue == 5 and first_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skull, position, 500)
				spawn_enemy_in_wave.emit(dog, position, 500)
			first_wave = true
		if timerValue == 4 and second_wave == false:
			for i in 10:
				spawn_enemy_in_wave.emit(dog, position, 500)
			second_wave = true
		if timerValue == 3 and third_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skeleton, position, 500)
			third_wave = true
		if timerValue == 2 and fourth_wave == false:
			for i in 7:
				spawn_enemy_in_wave.emit(skeleton, position, 600)
				spawn_enemy_in_wave.emit(skull, position, 600)
			fourth_wave = true
		if timerValue == 1 and fifth_wave == false:
			for i in 5:
				spawn_enemy_in_wave.emit(skeleton, position, 600)
				spawn_enemy_in_wave.emit(dog, position, 600)
				spawn_enemy_in_wave.emit(skull, position, 600)
			fifth_wave = true
