extends Node2D

@onready var options_menu: CanvasLayer = $options_menu 
@onready var loading_screen: TextureRect = $"Main Menu/LoadingScreen"

const first_timer_scene: PackedScene = preload("res://scenes/levels/first_time_player.tscn")
var scene_load_status = 0
var play_pressed: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameState.current_area = GameState.CURRENT_AREA.MAIN_MENU

	play_pressed = false
	scene_load_status = 0
	loading_screen.visible = false
	
func _process(_delta):
	if play_pressed == true:
		if GameState.first_time:
			get_tree().change_scene_to_packed(first_timer_scene)
		else:
			get_node("/root/menu").queue_free()
			get_tree().root.add_child(GameState.hell_area_to_instantiate.instantiate())
	
func _on_play_pressed():
	loading_screen.visible = true
	play_pressed = true

func _on_options_pressed():
	options_menu.visible = true
	visible = false

func _on_options_menu_go_back():
	options_menu.visible = false
	visible = true

