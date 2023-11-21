extends CanvasLayer

signal go_back

@export var master_test: AudioStreamPlayer
@export var SFX_test: AudioStreamPlayer
@export var damage_numbers_enabled: CheckButton

func _ready():
	damage_numbers_enabled.button_pressed = GameState.damage_numbers_enabled


func _on_master_slider_value_changed(value):
	if int(value * 100) % 10 == 0:
		master_test.play()


func _on_sfx_slider_value_changed(value):
	if int(value * 100) % 10 == 0:
		SFX_test.play()


func _on_back_pressed():
	go_back.emit()


func _on_damage_numbers_pressed():
	GameState.damage_numbers_enabled = damage_numbers_enabled.button_pressed
