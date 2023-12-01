extends Node

@export var HUD: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func first_dialogue():
	await get_tree().create_timer(2.0).timeout
	HUD.show_dialogue("Open your way out.")
	await get_tree().create_timer(4.0).timeout
	HUD.start_enemy_handler_and_magic_circles()
	await get_tree().create_timer(0.5).timeout
	HUD.show_dialogue("Find me.")
	await get_tree().create_timer(4.0).timeout
	HUD.show_dialogue("Don't let the denizens touch you.")
