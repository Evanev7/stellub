extends CanvasLayer

static var config_node_names = [
	"%Primary", "%Secondary", "%Tertiary", "%Passive"]
static var control_modes = [
	Attack.CONTROL_MODE.PRIMARY, Attack.CONTROL_MODE.SECONDARY, Attack.CONTROL_MODE.TERTIARY, Attack.CONTROL_MODE.PASSIVE]


# i didnt ever want to have to do this
# behold my most terrible move
func load_from_player():
	var player_attack_handler: Node2D = GameState.player.attack_handler
	var player_attacks: Array[Node] = player_attack_handler.get_children()
	var player_attack_count: int = player_attack_handler.get_child_count()

	for attack_index in range(4):
		var total_node: Control = get_node("%TotalAttack"+str(attack_index+1))
		var gui_attack_node: Control = total_node.get_node("%Attack")

		if attack_index >= player_attack_count:
			total_node.visible = false
			continue

		var player_attack_node: Attack = player_attacks[attack_index]
		var player_attack_upgrades: Array[Node] = player_attack_node.get_children()
		var attack_upgrade_count: int = player_attack_node.get_child_count()
		gui_attack_node.referenced_node = player_attack_node
		gui_attack_node.refresh()

		for config_index in range(4):
			var config_node: TextureButton = total_node.get_node(config_node_names[config_index])

			var update_player_attack = func(): player_attack_node.control_mode = control_modes[config_index]
			config_node.pressed.connect(update_player_attack)

		for upgrade_index in range(5):
			var upgrade_path: String = "%Upgrade" + str(upgrade_index+1)
			var gui_upgrade_node: Control = total_node.get_node(upgrade_path)

			if upgrade_index >= attack_upgrade_count:
				gui_upgrade_node.referenced_node = null
				continue

			var player_upgrade_node: Upgrade = player_attack_upgrades[upgrade_index]
			gui_upgrade_node.referenced_node = player_upgrade_node
			gui_upgrade_node.refresh()


# T O T A L C O D E D U P L I C A T I O N
func save_to_player():
	var player_attack_handler: Node2D = GameState.player.attack_handler
	var player_attacks: Array[Node] = player_attack_handler.get_children()
	
	for attack in player_attacks:
		player_attack_handler.remove_child(attack)
	
	for attack_index in range(4):
		var total_node: Control = get_node("%TotalAttack"+str(attack_index+1))
		var gui_attack_node: ShopDraggable = total_node.get_node("%Attack")
		assert(gui_attack_node.slot_type == ShopDraggable.SLOT_TYPE.ATTACK)
		var gui_attack: Attack = gui_attack_node.referenced_node

		if not gui_attack:
			continue
		
		player_attack_handler.add_child(gui_attack)

		var player_attack_node: Attack = player_attacks[attack_index]
		for upgrade in player_attack_node.get_children():
			player_attack_node.remove_child(upgrade)

		for upgrade_index in range(5):
			var upgrade_path: String = "%Upgrade" + str(upgrade_index+1)
			var gui_upgrade_node: ShopDraggable = total_node.get_node(upgrade_path)
			assert(gui_upgrade_node.slot_type == ShopDraggable.SLOT_TYPE.UPGRADE)
			var gui_upgrade = gui_upgrade_node.referenced_node
			
			if not gui_upgrade:
				continue
			
			player_attack_node.add_child(gui_upgrade)
	
	player_attack_handler.refresh_all_attacks()


func populate_shop(chosen_upgrades, weapon):
	pass


func open_shop(chosen_upgrades, weapon):
	load_from_player()
	populate_shop(chosen_upgrades, weapon)
	print(chosen_upgrades)
	print(weapon)


func close_shop():
	save_to_player()
	get_parent().get_tree().paused = false
	set_visible(false)
	


func _on_shop_exit_pressed():
	close_shop()
