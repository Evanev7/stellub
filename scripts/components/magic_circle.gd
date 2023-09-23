extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)

var current_wave
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


func _on_circle_body_entered(body):
	if body == GameState.player and wave_active == false:
		$Time.show()
		$WaveTimer.start()


func _on_circle_body_exited(body):
	if body == GameState.player:
		$Time.hide()
		$WaveTimer.stop()


func _on_wave_timer_timeout():
	$Time.hide()
	wave_active = true
	spawn_enemies()


func spawn_enemies():
	current_wave += 1
	$SuccessTimer.start()


func _on_success_timer_timeout():
	spawn_shop.emit(position)
