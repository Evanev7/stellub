extends Node2D

@onready var options_menu: CanvasLayer = $options_menu 
@onready var loading_screen: TextureRect = $"Main Menu/LoadingScreen"

const hell_scene: String = "scenes/levels/hell_area.tscn"
var scene_load_status = 0
var play_pressed: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ResourceLoader.load_threaded_request(hell_scene)
	play_pressed = false
	scene_load_status = 0
	loading_screen.visible = false
	
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(hell_scene)
	
	if play_pressed == true && scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(hell_scene))
	
func _on_play_pressed():
	loading_screen.visible = true
	play_pressed = true

func _on_options_pressed():
	options_menu.visible = true
	visible = false

func _on_options_menu_go_back():
	options_menu.visible = false
	visible = true

