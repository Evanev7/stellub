extends CanvasLayer

@export var main_menu_scene: PackedScene


func _on_hud_open_pause_menu():
	set_visible(true)
	GameState.pause_game()

func _on_continue_pressed():
	GameState.unpause_game()
	set_visible(false)


func _on_exit_pressed():
	GameState.unpause_game()
	get_tree().change_scene_to_packed(main_menu_scene)