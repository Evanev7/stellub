extends CanvasLayer

signal remove_shop
signal remove_weapon
signal apply_upgrade(upgrade)
signal add_weapon(weapon)

@export var weapon_button_group : ButtonGroup
var selected_weapon_button

var current_upgrades = []
var current_weapons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ShopScreen/Souls/SoulCount.text = str(GameState.player.souls)
	selected_weapon_button = weapon_button_group.get_pressed_button()
	
func show_HUD(chosen_upgrades, weapon):
	current_weapons = GameState.player.get_all_attacks()
	
	$ShopScreen/UpgradeButton1/Icon1.texture = chosen_upgrades[0].icon
	$ShopScreen/UpgradeButton2/Icon2.texture = chosen_upgrades[1].icon
	$ShopScreen/UpgradeButton3/Icon3.texture = chosen_upgrades[2].icon 
	$ShopScreen/UpgradeButton1/Label1.text = chosen_upgrades[0].name
	$ShopScreen/UpgradeButton2/Label2.text = chosen_upgrades[1].name
	$ShopScreen/UpgradeButton3/Label3.text = chosen_upgrades[2].name
	
	for i in current_weapons.size():
		weapon_button_group.get_buttons()[i].get_child(0).texture = current_weapons[i].initial_bullet.icon
		
	for button in weapon_button_group.get_buttons():
		if not button.get_child(0).texture:
			button.disabled = true
		else:
			button.disabled = false
	
	if weapon:
		$ShopScreen/WeaponButton.set_visible(true)
		$ShopScreen/WeaponButton/WeaponLabel.text = chosen_upgrades[3].name
		$ShopScreen/WeaponButton/WeaponIcon.texture = chosen_upgrades[3].icon
		
	current_upgrades = chosen_upgrades


func _on_upgrade_pressed(upgrade_number):
	for i in 3:
		if str(i) in selected_weapon_button.name:
			selected_weapon_button = i
			break
	GameState.player.upgrade_attack(current_upgrades[upgrade_number - 1], selected_weapon_button)
	GameState.player.evolve()
#	remove_upgrade.emit(current_upgrades[upgrade_number - 1])
	_on_leave_pressed()

func _on_weapon_button_pressed():
	GameState.player.add_attack_from_resource(current_upgrades[3])
	GameState.player.evolve()
	remove_weapon.emit(current_upgrades[3])
	_on_leave_pressed()
	
func _on_leave_pressed():
	$ShopScreen/WeaponButton.set_visible(false)
	get_parent().get_tree().paused = false
	set_visible(false)
	remove_shop.emit()

func _on_error_timer_timeout():
	$ShopScreen/Error.text = ""





