extends CanvasLayer

@export var main_menu_scene: PackedScene
@onready var options_menu: CanvasLayer = $options_menu

func _ready():
	GameState.pause_menu = self
	await get_tree().create_timer(2.1).timeout

	$Exit.disabled = false

func _on_hud_open_pause_menu():
	GameState.pause_game()
	set_visible(true)

func _on_continue_pressed():
	SoundManager.select.play()
	GameState.unpause_game()
	set_visible(false)

func _on_options_pressed():
	SoundManager.select.play()
	options_menu.visible = true
	visible = false

func _on_exit_pressed():
	SoundManager.select.play()
	GameState.unpause_game()
	Input.set_custom_mouse_cursor(GameState.clicky_hand, Input.CURSOR_ARROW, Vector2i(8,5))
	set_visible(false)
	if SoundManager.currently_playing_music:
		SoundManager.currently_playing_music.stop()
	GameState.load_area(GameState.CURRENT_AREA.MAIN_MENU)


func _on_options_menu_go_back():
	options_menu.visible = false
	visible = true


func _on_button_mouse_entered():
	SoundManager.button_hover.play()
