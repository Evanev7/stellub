extends Node2D

const hell_scene: String = "scenes/levels/hell_area.tscn"
var scene_load_status = 0
var play_pressed: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ResourceLoader.load_threaded_request(hell_scene)
	play_pressed = false
	scene_load_status = 0
	$CanvasLayer/LoadingScreen.visible = false
	
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(hell_scene)
	
	if play_pressed == true && scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(hell_scene))
	
func _on_play_pressed():
	$CanvasLayer/LoadingScreen.visible = true
	play_pressed = true
