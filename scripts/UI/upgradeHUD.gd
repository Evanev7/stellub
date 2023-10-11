extends CanvasLayer

signal remove_shop
signal remove_weapon
signal apply_upgrade(upgrade)
signal add_weapon(weapon)

var current_upgrades = []

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ColorRect/Souls/SoulCount.text = str(GameState.player.souls)
	
func show_HUD(chosen_upgrades, weapon):
	$ColorRect/UpgradeButton1/Icon1.texture = chosen_upgrades[0].icon
	$ColorRect/UpgradeButton2/Icon2.texture = chosen_upgrades[1].icon
	$ColorRect/UpgradeButton3/Icon3.texture = chosen_upgrades[2].icon 
	$ColorRect/UpgradeButton1/Label1.text = chosen_upgrades[0].name
	$ColorRect/UpgradeButton2/Label2.text = chosen_upgrades[1].name
	$ColorRect/UpgradeButton3/Label3.text = chosen_upgrades[2].name
	
	if weapon:
		$ColorRect/WeaponButton.set_visible(true)
		$ColorRect/WeaponButton/WeaponLabel.text = chosen_upgrades[3].name
		$ColorRect/WeaponButton/WeaponIcon.texture = chosen_upgrades[3].icon
		
	current_upgrades = chosen_upgrades


func _on_upgrade_pressed(upgrade_number): 
	GameState.player.upgrade_attacks(current_upgrades[upgrade_number - 1])
	GameState.player.evolve()
#	remove_upgrade.emit(current_upgrades[upgrade_number - 1])
	_on_leave_pressed()

func _on_weapon_button_pressed():
	GameState.player.add_attack_from_resource(current_upgrades[3])
	GameState.player.evolve()
	remove_weapon.emit(current_upgrades[3])
	_on_leave_pressed()
	
func _on_leave_pressed():
	$ColorRect/WeaponButton.set_visible(false)
	get_parent().get_tree().paused = false
	set_visible(false)
	remove_shop.emit()

func _on_error_timer_timeout():
	$ColorRect/Error.text = ""





