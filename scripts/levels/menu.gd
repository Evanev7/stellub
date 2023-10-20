extends Node2D

const main_scene: String = "scenes/levels/main.tscn"
var scene_load_status = 0
var progress = []
var play_pressed: bool = false

func _ready():
	ResourceLoader.load_threaded_request(main_scene)
	play_pressed = false
	scene_load_status = 0
	$CanvasLayer/LoadingScreen.visible = false
	
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(main_scene, progress)
	
	if play_pressed == true && scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(main_scene))
	
func _on_play_pressed():
	$CanvasLayer/LoadingScreen.visible = true
	play_pressed = true
