extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)
signal spawn_teleporter()
signal spawn_enemy_in_wave(resource)

static var current_circle: int = 1
var wave_active: bool = false

####
var skull = 0
var dog = 1
var skeleton = 2
var worshipper = 3
####

var wave_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("magic_circle")
	start()

func start():
	get_node("Circle/CollisionShape2D").disabled = false
	current_circle = 1
	wave_active = false
	set_waves()
	$WaveTimer.stop()
	$Time.hide()
	$SuccessTimer.wait_time = 30
	
func set_waves():
	wave_data = {
		1: {
			0: {skull: 10},
			2: {skull: 10},
			1: {dog: 10},
		},
		2: {
			0: {skull: 10},
			3: {skull: 10},
			2: {dog: 10},
			1: {skeleton: 10},
		},
		3: {
			0: {skull: 10},
			4: {skull: 10},
			3: {dog: 10},
			2: {skeleton: 10},
			1: {skeleton: 10},
		},
		4: {
			0: {skull: 10},
			5: {skull: 10},
			4: {dog: 20},
			3: {skeleton: 10},
			2: {skeleton: 15, skull: 15},
			1: {skeleton: 10, dog: 10, skull: 10},
		},
		5: {
			0: {skull: 10},
			6: {skull: 10},
			5: {dog: 20},
			4: {skeleton: 10},
			3: {skeleton: 15, skull: 15},
			2: {skeleton: 10, dog: 10, skull: 10},
			1: {skeleton: 10, dog: 10, skull: 10}
		},
		6: {
			0: {skeleton: 10, dog: 10, skull: 10},
			7: {skeleton: 10, dog: 10, skull: 10},
			6: {skeleton: 30},
			5: {skull: 50},
			4: {skeleton: 20, skull: 20},
			3: {skeleton: 20, dog: 20, skull: 20},
			2: {skeleton: 20, dog: 20, skull: 30},
			1: {skeleton: 30, dog: 30, skull: 30}
		},
		7: {
			0: {skeleton: 10, dog: 10, skull: 10},
			8: {skeleton: 10, dog: 10, skull: 10},
			7: {skeleton: 30},
			6: {skull: 50},
			5: {skeleton: 20, skull: 20},
			4: {skeleton: 20, dog: 20, skull: 20},
			3: {skeleton: 20, dog: 20, skull: 30},
			2: {skeleton: 30, dog: 30, skull: 30},
			1: {worshipper: 5, skeleton: 30, dog: 30, skull: 30}
		},
		8: {
			0: {skull: 10},
			9: {skull: 10},
			8: {dog: 20},
			7: {skeleton: 10},
			6: {skeleton: 15, skull: 15},
			5: {skeleton: 10, dog: 10, skull: 10},
			4: {skeleton: 10, dog: 10, skull: 10},
			3: {skeleton: 10, dog: 10, skull: 10},
			2: {skeleton: 10, dog: 10, skull: 10},
			1: {skeleton: 10, dog: 10, skull: 10},
		},
		9: {
			0: {skull: 10},
			10: {skull: 10},
			9: {dog: 20},
			8: {skeleton: 10},
			7: {skeleton: 15, skull: 15},
			6: {skeleton: 10, dog: 10, skull: 10},
			5: {skeleton: 10, dog: 10, skull: 10},
			4: {skeleton: 10, dog: 10, skull: 10},
			3: {skeleton: 10, dog: 10, skull: 10},
			2: {skeleton: 10, dog: 10, skull: 10},
			1: {skeleton: 10, dog: 10, skull: 10},
		},
		10: {
			0: {skull: 10},
			11: {skull: 10},
			10: {dog: 20},
			9: {skeleton: 10},
			8: {skeleton: 15, skull: 15},
			7: {skeleton: 10, dog: 10, skull: 10},
			6: {skeleton: 10, dog: 10, skull: 10},
			5: {skeleton: 10, dog: 10, skull: 10},
			4: {skeleton: 10, dog: 10, skull: 10},
			3: {skeleton: 10, dog: 10, skull: 10},
			2: {skeleton: 10, dog: 10, skull: 10},
			1: {skeleton: 10, dog: 10, skull: 10},
		},
	}

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
	wave_active = false
	$Time.hide()
	if current_circle < 12:
		current_circle += 1
		get_node("Circle/CollisionShape2D").disabled = true
	if current_circle == 2:
		spawn_teleporter.emit()
	
	
func spawn_enemies(timerValue):
	var wave = wave_data[current_circle][timerValue]
	wave_data[current_circle][timerValue] = null
	if wave:
		for i in range(wave.size()):
			var enemy_type = wave.keys()[i]
			var count = wave.values()[i]
			for j in range(count):
				spawn_enemy_in_wave.emit(enemy_type, position, 500)
