extends Node

@onready var heaven_start: AudioStreamPlayer = $heaven_start
@onready var heaven_loop: AudioStreamPlayer = $heaven_loop
@onready var hell_song: AudioStreamPlayer = $hell_song
@onready var merchant_dialogue = $merchant_dialogue
@onready var important_select = $important_select
@onready var select = $select
@onready var button_hover = $button_hover
@onready var place_upgrade = $place_upgrade

var currently_playing_music: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if heaven_start.get_playback_position() >= 24.31 and currently_playing_music == heaven_start:
		_on_heaven_start_finished()
	
func heaven_start_play():
	heaven_start.volume_db = -6
	heaven_start.play()
	currently_playing_music = heaven_start

func _on_heaven_start_finished():
	heaven_loop.volume_db = -6
	heaven_loop.play()
	currently_playing_music = heaven_loop

func hell_song_play():
	hell_song.volume_db = -6
	hell_song.play()
	currently_playing_music = hell_song

func fade_out(stream):
	var tween: Tween = create_tween()
	tween.tween_property(stream, "volume_db", -80, 2).from(linear_to_db(0.4))
	tween.tween_callback(stream.stop)
	stream.volume_db = -6
	currently_playing_music = null
