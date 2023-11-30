extends Node

@onready var heaven_start = $heaven_start
@onready var heaven_loop = $heaven_loop

var currently_playing_music: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if heaven_start.get_playback_position() >= 24.31 and currently_playing_music == heaven_start:
		_on_heaven_start_finished()
	
func heaven_start_play():
	heaven_start.play()
	currently_playing_music = heaven_start

func _on_heaven_start_finished():
	heaven_loop.play()
	currently_playing_music = heaven_loop


func fade_out(stream):
	var tween: Tween = create_tween()
	tween.tween_property(stream, "volume_db", -80, 2).from(linear_to_db(0.4))
	tween.tween_callback(stream.stop)
