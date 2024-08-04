extends CanvasLayer

signal go_back

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider
@export var master_test: AudioStreamPlayer
@export var SFX_test: AudioStreamPlayer
@export var damage_numbers_enabled: CheckButton
@export var fps_enabled: CheckButton

func _ready():
	damage_numbers_enabled.button_pressed = GameState.player_data.damage_numbers_enabled
	fps_enabled.button_pressed = GameState.player_data.fps_enabled
	master_slider.value = GameState.player_data.master_volume
	sfx_slider.value = GameState.player_data.sfx_volume
	music_slider.value = GameState.player_data.music_volume


func _on_master_slider_value_changed(value):
	if int(value * 100) % 11 == 0:
		master_test.play()


func _on_sfx_slider_value_changed(value):
	if int(value * 100) % 11 == 0:
		SFX_test.play()


func _on_back_pressed():
	SoundManager.select.play()
	GameState.save_game()
	go_back.emit()


func _on_damage_numbers_pressed():
	SoundManager.select.play()
	GameState.player_data.damage_numbers_enabled = damage_numbers_enabled.button_pressed


func _on_fps_pressed():
	SoundManager.select.play()
	GameState.player_data.fps_enabled = fps_enabled.button_pressed


func _on_back_mouse_entered():
	SoundManager.button_hover.play()
