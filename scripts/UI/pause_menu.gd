extends CanvasLayer

signal unpause_game

@export var main_menu_scene: PackedScene

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_hud_open_pause_menu():
	set_visible(true)

func _on_continue_pressed():
	unpause_game.emit()
	set_visible(false)


func _on_exit_pressed():
	unpause_game.emit()
	get_tree().change_scene_to_packed(main_menu_scene)
