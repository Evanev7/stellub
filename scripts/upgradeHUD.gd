extends CanvasLayer

signal leave

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ColorRect/Souls/SoulCount.text = str(GameState.player.souls)
	
func show_HUD(stat_upgrades):
	$ColorRect/Upgrade1.text = stat_upgrades[0].NAME 
	$ColorRect/Upgrade2.text = stat_upgrades[1].NAME 
	$ColorRect/Upgrade3.text = stat_upgrades[2].NAME 
	$ColorRect/Upgrade1/Label1.text = str(stat_upgrades[0].COST)
	$ColorRect/Upgrade2/Label2.text = str(stat_upgrades[1].COST)
	$ColorRect/Upgrade3/Label3.text = str(stat_upgrades[2].COST)

func _on_upgrade_1_pressed():
	if GameState.player.souls < int($ColorRect/Upgrade1/Label1.text):
		$ColorRect/Error.text = "You can't afford this."
		$ErrorTimer.start()
	else:
		GameState.player.souls -= int($ColorRect/Upgrade1/Label1.text)
		GameState.player.current_evolution += int($ColorRect/Upgrade1/Label1.text)
		GameState.player.stat_upgrade($ColorRect/Upgrade1.text)
	
func _on_upgrade_2_pressed():
	if GameState.player.souls < int($ColorRect/Upgrade2/Label2.text):
		$ColorRect/Error.text = "You can't afford this."
		$ErrorTimer.start()
	else:
		GameState.player.souls -= int($ColorRect/Upgrade2/Label2.text)
		GameState.player.current_evolution += int($ColorRect/Upgrade2/Label2.text)
		GameState.player.stat_upgrade($ColorRect/Upgrade2.text)

func _on_upgrade_3_pressed():
	if GameState.player.souls < int($ColorRect/Upgrade3/Label3.text):
		$ColorRect/Error.text = "You can't afford this."
		$ErrorTimer.start()
	else:
		GameState.player.souls -= int($ColorRect/Upgrade3/Label3.text)
		GameState.player.current_evolution += int($ColorRect/Upgrade3/Label3.text)
		GameState.player.stat_upgrade($ColorRect/Upgrade3.text)

func _on_leave_pressed():
	leave.emit()
	set_visible(false)

func _on_error_timer_timeout():
	$ColorRect/Error.text = ""



