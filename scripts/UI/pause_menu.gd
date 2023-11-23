extends CanvasLayer

@export var main_menu_scene: PackedScene
@onready var options_menu: CanvasLayer = $options_menu 

func _ready():
	GameState.pause_menu = self

func _on_hud_open_pause_menu():
	GameState.pause_game()
	set_visible(true)

func _on_continue_pressed():
	GameState.unpause_game()
	set_visible(false)

func _on_options_pressed():
	options_menu.visible = true
	visible = false
	
func _on_exit_pressed():
	GameState.unpause_game()
	get_parent().queue_free()
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_options_menu_go_back():
	options_menu.visible = false
	visible = true


