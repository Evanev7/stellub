extends Node2D

@onready var options_menu: CanvasLayer = $options_menu 
@onready var stat_screen: CanvasLayer = $stat_screen 
@onready var loading_screen: TextureRect = $"Main Menu/LoadingScreen"

var scene_load_status = 0
var play_pressed: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameState.current_area = GameState.CURRENT_AREA.MAIN_MENU

	play_pressed = false
	scene_load_status = 0
	loading_screen.visible = false
	
	
	if GameState.debug:
		$"Main Menu/Background/Buttons/FirstTime".visible = true
		$"Main Menu/Background/Buttons/FirstTime".button_pressed = GameState.player_data.first_time


func _on_play_pressed():
	loading_screen.visible = true
	play_pressed = true
	load_game()

func load_game():
		if GameState.player_data.first_time:
			GameState.load_area(GameState.CURRENT_AREA.FIRST_TIME)
		else:
			GameState.load_area(GameState.CURRENT_AREA.HELL)
		loading_screen.visible = false
	

func _on_options_pressed():
	options_menu.visible = true
	visible = false

func _on_stats_pressed():
	stat_screen.opened_via_main()
	visible = false
	
func _on_options_menu_go_back():
	options_menu.visible = false
	visible = true

func _on_first_time_toggled(button_pressed):
	GameState.player_data.first_time = button_pressed
	GameState.player_data.first_time_shop = button_pressed


