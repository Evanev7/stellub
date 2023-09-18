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


func _on_upgrade_pressed(upgrade_number):
	var upgrade_label = "ColorRect/Upgrade" + str(upgrade_number) + "/Label" + str(upgrade_number)
	var upgrade_text = "ColorRect/Upgrade" + str(upgrade_number)
	var cost = int(get_node(upgrade_label).text)
	
	if GameState.player.souls < cost:
		$ColorRect/Error.text = "You can't afford this."
		$ErrorTimer.start()
	else:
		GameState.player.souls -= cost
		
		# Eventually this should be a calculation that figures out what evolution
		# the character should be on
		GameState.player.current_evolution += cost
		
		GameState.player.stat_upgrade(get_node(upgrade_text).text)

func _on_leave_pressed():
	leave.emit()
	set_visible(false)

func _on_error_timer_timeout():
	$ColorRect/Error.text = ""



