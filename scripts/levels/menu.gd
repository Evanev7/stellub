extends Node2D

@onready var options_menu: CanvasLayer = $options_menu
@onready var stat_screen: CanvasLayer = $stat_screen
@onready var loading_screen: TextureRect = $"Main Menu/LoadingScreen"
@onready var credits_screen = $credits_screen

var scene_load_status = 0
var play_pressed: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameState.current_area = GameState.CURRENT_AREA.MAIN_MENU
	SoundManager.main_menu_song_play()

	play_pressed = false
	scene_load_status = 0
	loading_screen.visible = false


	if GameState.debug:
		$"Main Menu/Background/Buttons/FirstTime".visible = true
		$"Main Menu/Background/Buttons/FirstTime".button_pressed = GameState.player_data.first_time


func _on_play_pressed():
	SoundManager.important_select.play()
	loading_screen.visible = true
	play_pressed = true
	SoundManager.fade_out(SoundManager.currently_playing_music)
	load_game()

func load_game():
		if GameState.player_data.first_time:
			GameState.load_area(GameState.CURRENT_AREA.FIRST_TIME)
		else:
			GameState.load_area(GameState.CURRENT_AREA.HELL)
		loading_screen.visible = false


func _on_options_pressed():
	SoundManager.select.play()
	options_menu.visible = true
	visible = false

func _on_stats_pressed():
	SoundManager.select.play()
	stat_screen.opened_via_main()
	visible = false

func _on_credits_pressed():
	SoundManager.select.play()
	credits_screen.visible = true
	visible = false

func _on_credits_go_back():
	SoundManager.select.play()
	credits_screen.visible = false
	visible = true

func _on_options_menu_go_back():
	SoundManager.select.play()
	options_menu.visible = false
	visible = true

func _on_first_time_toggled(button_pressed):
	GameState.player_data.first_time = button_pressed
	GameState.player_data.first_time_heaven = button_pressed
	GameState.player_data.first_time_boss = button_pressed
	GameState.player_data.first_time_shop = button_pressed



func _on_button_mouse_entered():
	SoundManager.button_hover.play()
