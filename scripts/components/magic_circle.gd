extends Node2D

signal shop_entered
@export var shop_scene: PackedScene
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
	$Time.text = str(int($WaveTimer.get_time_left()) + 1)


func _on_circle_body_entered(body):
	if body == GameState.player && wave_active == false:
		$Time.show()
		$WaveTimer.start()


func _on_circle_body_exited(body):
	if body == GameState.player:
		$Time.hide()
		$WaveTimer.stop()


func _on_wave_timer_timeout():
	$Time.hide()
	wave_active = true
	spawn_enemies(current_wave)


func spawn_enemies(wave):
	print("wave " + str(wave))
	current_wave += 1
	$SuccessTimer.start()
	

func _on_success_timer_timeout():
	spawn_shop(self)

func spawn_shop(magic_circle):
	print("shop spawn attempt")
	var shop = shop_scene.instantiate()
	shop.show()
	shop.position = Vector2(magic_circle.position.x, magic_circle.position.y)
	print(shop.position)
	print(magic_circle.position)
	add_child(shop)
	shop.connect('shop_entered', shop_entered_signal)

func shop_entered_signal():
	shop_entered.emit()
