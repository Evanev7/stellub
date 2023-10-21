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
var seventh_wave: bool = false
var eigth_wave: bool = false
var ninth_wave: bool = false
var tenth_wave: bool = false

####
var skull = 0
var dog = 1
var skeleton = 2
####

var wave_data = {
	1: {
		0: {skull: 5},
		2: {skull: 5},
		1: {dog: 5},
	},
	2: {
		0: {skull: 5},
		3: {skull: 5},
		2: {dog: 5},
		1: {skeleton: 5},
	},
	3: {
		0: {skull: 5},
		4: {skull: 5},
		3: {dog: 5},
		2: {skeleton: 5},
		1: {skeleton: 10},
	},
	4: {
		0: {skull: 5},
		5: {skull: 5},
		4: {dog: 10},
		3: {skeleton: 5},
		2: {skeleton: 7, skull: 7},
		1: {skeleton: 5, dog: 5, skull: 5},
	}
}

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
	seventh_wave = false
	eigth_wave = false
	ninth_wave = false
	tenth_wave = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Time.text = str(int($WaveTimer.get_time_left() + 0.99))
	
	if wave_active:
		$Time.text = str(int($SuccessTimer.get_time_left()))
		if int($SuccessTimer.get_time_left()) % 10 == 0 && $SuccessTimer.get_time_left() > 1:
			spawn_enemies(int($SuccessTimer.get_time_left()) / 10)


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
	$SuccessTimer.wait_time = 20 + (9.99 * current_circle)
	$SuccessTimer.start()
	spawn_enemies(0)


func _on_success_timer_timeout():
	spawn_shop.emit(position)
	reset_bools()
	wave_active = false
	$Time.hide()
	current_circle += 1
	get_node("Circle/CollisionShape2D").disabled = true


#func spawn_enemies(timerValue):
#	var skull = 0
#	var dog = 1
#	var skeleton = 2
#	if current_circle == 1:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 2 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#			first_wave = true
#		if timerValue == 1 and second_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#
#	if current_circle == 2:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 3 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#			first_wave = true
#		if timerValue == 2 and second_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#		if timerValue == 1 and third_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 500)
#			third_wave = true
#
#	if current_circle == 3:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 4 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#			first_wave = true
#		if timerValue == 3 and second_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#		if timerValue == 2 and third_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 500)
#			third_wave = true
#		if timerValue == 1 and fourth_wave == false:
#			for i in 7:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#			fourth_wave = true
#
#	if current_circle == 4:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 5 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			first_wave = true
#		if timerValue == 4 and second_wave == false:
#			for i in 10:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#		if timerValue == 3 and third_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 500)
#			third_wave = true
#		if timerValue == 2 and fourth_wave == false:
#			for i in 7:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fourth_wave = true
#		if timerValue == 1 and fifth_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fifth_wave = true
#
#	if current_circle == 5:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 6 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			first_wave = true
#		if timerValue == 5 and second_wave == false:
#			for i in 10:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#		if timerValue == 4 and third_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 500)
#			third_wave = true
#		if timerValue == 3 and fourth_wave == false:
#			for i in 7:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fourth_wave = true
#		if timerValue == 2 and fifth_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fifth_wave = true
#		if timerValue == 1 and sixth_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			sixth_wave = true
#
#	if current_circle == 6:
#		if timerValue == 0:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#		if timerValue == 7 and first_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skull, position, 500)
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			first_wave = true
#		if timerValue == 6 and second_wave == false:
#			for i in 10:
#				spawn_enemy_in_wave.emit(dog, position, 500)
#			second_wave = true
#		if timerValue == 5 and third_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 500)
#			third_wave = true
#		if timerValue == 4 and fourth_wave == false:
#			for i in 7:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fourth_wave = true
#		if timerValue == 3 and fifth_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			fifth_wave = true
#		if timerValue == 2 and sixth_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			sixth_wave = true
#		if timerValue == 1 and seventh_wave == false:
#			for i in 5:
#				spawn_enemy_in_wave.emit(skeleton, position, 600)
#				spawn_enemy_in_wave.emit(dog, position, 600)
#				spawn_enemy_in_wave.emit(skull, position, 600)
#			seventh_wave = true
			
func spawn_enemies(timerValue):
	print(timerValue)
	var wave = wave_data[current_circle][timerValue]
	wave_data[current_circle][timerValue] = null
	if wave:
		for i in range(wave.size()):
			var enemy_type = wave.keys()[i]
			var count = wave.values()[i]
			for j in range(count):
				spawn_enemy_in_wave.emit(enemy_type, position, 500)
