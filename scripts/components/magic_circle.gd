extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)
signal activate_teleporter
signal spawn_enemy_in_wave(resource)
signal add_to_hud(circle)
signal remove_from_hud(circle)
signal spawn_next_circle(origin)

var wave_active: bool = false

####
enum {skull, dog, skeleton, lord}
####

@onready var barrier_edge_marker: Node2D = $Barrier/Marker2D
@onready var success_timer: Timer = $SuccessTimer
@onready var time_label: Label = $Time
@onready var activated_sound: AudioStreamPlayer2D = $activated_sound
@onready var finished_sound: AudioStreamPlayer2D = $finished_sound


var wave_data = {}
var distance_from_center: float = 0
var size_of_barrier: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_hud.emit(self)
	add_to_group("magic_circle")
	start()


func start():
	get_node("Circle/CollisionShape2D").disabled = false
	wave_active = false
	set_waves()
	$WaveTimer.stop()
	time_label.hide()
	success_timer.wait_time = 30
	
func set_waves():
	wave_data = {
		1: {
			2: {skull: 5},
			1: {dog: 5},
		},
		2: {
			3: {skull: 10},
			2: {dog: 5},
			1: {skeleton: 5},
		},
		3: {
			4: {skull: 15},
			3: {dog: 10},
			2: {skeleton: 10},
			1: {skeleton: 5},
		},
		4: {
			5: {skull: 20},
			4: {dog: 20},
			3: {skeleton: 15},
			2: {skeleton: 15, skull: 15},
			1: {skeleton: 10, dog: 10, skull: 10},
		},
		5: {
			6: {skull: 30},
			5: {dog: 20},
			4: {skeleton: 20},
			3: {skeleton: 15, skull: 15},
			2: {skeleton: 15, dog: 15, skull: 15},
			1: {skeleton: 10, dog: 10, skull: 10}
		},
		6: {
			7: {skeleton: 10, dog: 10, skull: 10},
			6: {skeleton: 30},
			5: {skull: 50},
			4: {skeleton: 20, skull: 20},
			3: {skeleton: 20, dog: 20, skull: 20},
			2: {skeleton: 20, dog: 20, skull: 40},
			1: {lord: 2, skeleton: 15, dog: 15}
		},
		7: {
			8: {skeleton: 20, dog: 20, skull: 20},
			7: {skeleton: 30, dog: 10},
			6: {lord: 1, skeleton: 20},
			5: {dog: 20, skull: 50},
			4: {skeleton: 20, skull: 30},
			3: {skeleton: 25, dog: 25, skull: 25},
			2: {skeleton: 25, dog: 25, skull: 45},
			1: {lord: 2, skeleton: 15, dog: 15}
		},
		8: {
			9: {skeleton: 30, dog: 30, skull: 30},
			8: {skeleton: 20, dog: 20, skull: 20},
			7: {skeleton: 30, dog: 10},
			6: {lord: 1, skeleton: 20},
			5: {dog: 20, skull: 50},
			4: {skeleton: 20, skull: 30},
			3: {skeleton: 25, dog: 25, skull: 25},
			2: {skeleton: 25, dog: 25, skull: 45},
			1: {lord: 2, skeleton: 15, dog: 15}
		},
		9: {
			10: {skeleton: 30, dog: 30, skull: 30},
			9: {skeleton: 30, dog: 30, skull: 30},
			8: {skeleton: 30, dog: 30, skull: 30},
			7: {skeleton: 80},
			6: {skull: 200},
			5: {skeleton: 60, skull: 60},
			4: {skeleton: 80, dog: 80, skull: 80},
			3: {skeleton: 80, dog: 80, skull: 100},
			2: {skeleton: 80, dog: 80, skull: 100},
			1: {lord: 10, skeleton: 40, dog: 40, skull: 40}
		},
		10: {
			11: {skeleton: 30, dog: 30, skull: 30},
			10: {skeleton: 30, dog: 30, skull: 30},
			9: {skeleton: 30, dog: 30, skull: 30},
			8: {skeleton: 30, dog: 30, skull: 30},
			7: {skeleton: 80},
			6: {skull: 200},
			5: {skeleton: 60, skull: 60},
			4: {skeleton: 80, dog: 80, skull: 80},
			3: {skeleton: 80, dog: 80, skull: 100},
			2: {skeleton: 80, dog: 80, skull: 100},
			1: {lord: 10, skeleton: 40, dog: 40, skull: 40}
		},
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	time_label.text = str(int($WaveTimer.get_time_left() + 0.99))
	
	if wave_active:
		size_of_barrier = barrier_edge_marker.global_position.distance_to(self.global_position)
		distance_from_center = GameState.player.position.distance_to(self.position)
		GameState.player.global_position = to_global(to_local(GameState.player.global_position).limit_length(size_of_barrier))
			
		time_label.text = str(int(success_timer.get_time_left()))
		if int(success_timer.get_time_left()) % 10 == 0 && success_timer.get_time_left() > 1:
			spawn_enemies(int(success_timer.get_time_left()) / 10)


func _on_circle_body_entered(body):
	if body == GameState.player and not wave_active:
		time_label.show()
		$WaveTimer.start()


func _on_circle_body_exited(body):
	if body == GameState.player:
		if not wave_active:
			time_label.hide()
		$WaveTimer.stop()


func _on_wave_timer_timeout():
	wave_active = true
	success_timer.wait_time = 10 + (9.99 * GameState.circles_completed + 1)
	$Barrier.visible = true
	activated_sound.play()
	var tween: Tween = create_tween()
	tween.parallel().tween_property(activated_sound, "volume_db", 10, success_timer.wait_time).from(-20).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Barrier, "scale", Vector2(0.4, 0.4), success_timer.wait_time)
	tween.parallel().tween_property($Active, "modulate:a", 0.9, success_timer.wait_time)
	success_timer.start()
	spawn_enemies((GameState.circles_completed + 1))


func _on_success_timer_timeout():
	spawn_shop.emit(position)
	$Cleared.visible = true
	wave_active = false
	SoundManager.fade_out(activated_sound)
	finished_sound.play()
	$Barrier.visible = false
	time_label.hide()
	if GameState.circles_completed + 1 < 12:
		GameState.circles_completed += 1
		remove_objective_marker()
		get_node("Circle/CollisionShape2D").disabled = true
		spawn_next_circle.emit(self.global_position)
	if GameState.circles_completed + 1 == 7:
		activate_teleporter.emit()
	
func remove_objective_marker():
	remove_from_hud.emit(self)
	
	
func spawn_enemies(timerValue):
	var wave_index = clamp(GameState.circles_completed, 1, 10)
	
	var wave = wave_data[wave_index][timerValue]
	wave_data[wave_index][timerValue] = null
	if wave:
		for i in range(wave.size()):
			var enemy_type = wave.keys()[i]
			var count = wave.values()[i]
			for j in range(count):
				if size_of_barrier == 0:
					size_of_barrier = 500
				spawn_enemy_in_wave.emit(enemy_type, position, 750)
