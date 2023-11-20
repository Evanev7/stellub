extends CanvasLayer

signal go_back

@export var master_test: AudioStreamPlayer
@export var SFX_test: AudioStreamPlayer


func _on_master_slider_value_changed(value):
	if int(value * 100) % 10 == 0:
		master_test.play()


func _on_sfx_slider_value_changed(value):
	if int(value * 100) % 10 == 0:
		SFX_test.play()


func _on_back_pressed():
	go_back.emit()
