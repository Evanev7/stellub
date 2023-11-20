extends Node2D

#This can be re-enabled if we want to change magic_circle behaviour
#signal shop_entered
signal spawn_shop(location: Vector2)
signal activate_teleporter()
signal spawn_enemy_in_wave(resource)
signal remove_circle_from_objective_marker(circle)

static var current_circle: int = 1
var wave_active: bool = false

####
enum {skull, dog, skeleton, lord}
####

@onready var barrier_edge_marker: Node2D = $Barrier/Marker2D
@onready var success_timer: Timer = $SuccessTimer
@onready var time_label: Label = $Time

var wave_data = {}
var distance_from_center: float = 0
var size_of_barrier: float = 0

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
	time_label.hide()
	success_timer.wait_time = 30
	
func set_waves():
	wave_data = {
		1: {
			3: {skull: 10},
			2: {skull: 10},
			1: {dog: 10},
		},
		2: {
			4: {skull: 10},
			3: {skull: 10},
			2: {dog: 10},
			1: {skeleton: 10},
		},
		3: {
			5: {skull: 15},
			4: {skull: 20},
			3: {dog: 20},
			2: {skeleton: 20},
			1: {skeleton: 20},
		},
		4: {
			6: {skull: 20},
			5: {skull: 30},
			4: {dog: 30},
			3: {skeleton: 30},
			2: {skeleton: 20, skull: 20},
			1: {skeleton: 15, dog: 15, skull: 15},
		},
		5: {
			7: {skull: 40},
			6: {skull: 50},
			5: {dog: 40},
			4: {skeleton: 40},
			3: {skeleton: 20, skull: 20},
			2: {skeleton: 20, dog: 20, skull: 20},
			1: {skeleton: 30, dog: 30, skull: 30}
		},
		6: {
			8: {skeleton: 20, dog: 20, skull: 20},
			7: {skeleton: 30, dog: 30, skull: 30},
			6: {skeleton: 50},
			5: {skull: 100},
			4: {skeleton: 50, skull: 50},
			3: {skeleton: 50, dog: 50, skull: 50},
			2: {skeleton: 50, dog: 50, skull: 60},
			1: {skeleton: 40, dog: 40, skull: 50}
		},
		7: {
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
		8: {
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
		9: {
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
		10: {
			12: {skeleton: 30, dog: 30, skull: 30},
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
	success_timer.wait_time = 20 + (9.99 * current_circle)
	$Barrier.visible = true
	$Barrier/CollisionPolygon2D.disabled = false
	var tween: Tween = create_tween()
	tween.tween_property($Barrier, "scale", Vector2(0.4, 0.4), success_timer.wait_time)
	success_timer.start()
	spawn_enemies((current_circle + 2))


func _on_success_timer_timeout():
	spawn_shop.emit(position)
	wave_active = false
	$Barrier.visible = false
	$Barrier/CollisionPolygon2D.disabled = true
	time_label.hide()
	if current_circle < 12:
		current_circle += 1
		remove_objective_marker(self)
		get_node("Circle/CollisionShape2D").disabled = true
	if current_circle == 11:
		activate_teleporter.emit()
	
func remove_objective_marker(circle):
	remove_circle_from_objective_marker.emit(circle)
	
	
func spawn_enemies(timerValue):
	var wave_index = clamp(current_circle+5,1,10)
	
	var wave = wave_data[wave_index][timerValue]
	wave_data[wave_index][timerValue] = null
	if wave:
		for i in range(wave.size()):
			var enemy_type = wave.keys()[i]
			var count = wave.values()[i]
			for j in range(count):
				if size_of_barrier == 0:
					size_of_barrier = 500
				spawn_enemy_in_wave.emit(enemy_type, position, size_of_barrier - 50)
