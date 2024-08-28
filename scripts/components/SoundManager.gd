extends Node

@onready var heaven_loop: AudioStreamPlayer = $heaven_loop
@onready var hell_song: AudioStreamPlayer = $hell_song
@onready var merchant_dialogue = $merchant_dialogue
@onready var important_select = $important_select
@onready var select = $select
@onready var button_hover = $button_hover
@onready var place_upgrade = $place_upgrade
@onready var main_menu = $main_menu
@onready var boss_song = $boss_song
@onready var landing_sfx: AudioStreamPlayer = $LandingSFX


var currently_playing_music: AudioStreamPlayer


func heaven_start_play():
	heaven_loop.volume_db = 0
	heaven_loop.play(0)
	currently_playing_music = heaven_loop

func hell_song_play():
	hell_song.volume_db = 0
	hell_song.play()
	currently_playing_music = hell_song

func main_menu_song_play():
	main_menu.volume_db = 0
	main_menu.play()
	currently_playing_music = main_menu

func boss_song_play():
	boss_song.volume_db = 0
	boss_song.play()
	currently_playing_music = boss_song

func fade_out(stream):
	var tween: Tween = create_tween()
	tween.tween_property(stream, "volume_db", -80, 2).from(linear_to_db(0.4))
	tween.tween_callback(func():
		stream.volume_db = 0
		stream.stop()
		)
