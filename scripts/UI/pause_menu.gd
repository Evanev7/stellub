extends CanvasLayer

signal unpause_game

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_hud_open_pause_menu():
	set_visible(true)

func _on_continue_pressed():
	unpause_game.emit()
	set_visible(false)


