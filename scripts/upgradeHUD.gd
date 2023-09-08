extends CanvasLayer

signal upgrade_1_pressed
signal upgrade_2_pressed
signal upgrade_3_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func show_level(current_level):
	$ColorRect/LevelUpDisplay.text = "Level " + str(current_level) + "!"

func _on_upgrade_1_pressed():
	upgrade_1_pressed.emit()
	
func _on_upgrade_2_pressed():
	upgrade_2_pressed.emit()

func _on_upgrade_3_pressed():
	upgrade_3_pressed.emit()



