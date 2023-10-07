extends CanvasLayer

signal leave
signal remove_shop
signal remove_upgrade

var current_upgrades = []

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ColorRect/Souls/SoulCount.text = str(GameState.player.souls)
	
func show_HUD(chosen_upgrades):
	$ColorRect/UpgradeButton1/Icon1.texture = chosen_upgrades[0].icon
	$ColorRect/UpgradeButton2/Icon2.texture = chosen_upgrades[1].icon
	$ColorRect/UpgradeButton3/Icon3.texture = chosen_upgrades[2].icon 
	$ColorRect/UpgradeButton1/Label1.text = chosen_upgrades[0].name
	$ColorRect/UpgradeButton2/Label2.text = chosen_upgrades[1].name
	$ColorRect/UpgradeButton3/Label3.text = chosen_upgrades[2].name
	
	current_upgrades = chosen_upgrades


func _on_upgrade_pressed(upgrade_number):
	GameState.player.upgrade_attacks(current_upgrades[upgrade_number - 1])
	GameState.player.evolve()
#	remove_upgrade.emit(current_upgrades[upgrade_number - 1])
	_on_leave_pressed()


func _on_leave_pressed():
	get_parent().get_tree().paused = false
	set_visible(false)
	remove_shop.emit()

func _on_error_timer_timeout():
	$ColorRect/Error.text = ""



