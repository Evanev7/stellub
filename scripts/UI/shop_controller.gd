extends CanvasLayer


signal remove_shop

enum {SAVE, LOAD}

@export var num_gui_attacks = 4

var shop_attached_to

func get_attack_nodes(parent: Node) -> Array[Attack]:
	var nodes: Array[Attack] = []
	for child in parent.get_children():
		if child is Attack:
			nodes.append(child)
	return nodes


func get_gui_total_attacks() -> Array[Control]:
	var gui_total_attacks: Array[Control] = []
	for index in range(num_gui_attacks):
		gui_total_attacks.append(get_node("%TotalAttack"+str(index+1)))
	return gui_total_attacks

func get_gui_attacks() -> Array[ShopDraggable]:
	var gui_attack: Array[ShopDraggable] = []
	for total_attack in get_gui_total_attacks():
		gui_attack.append(total_attack.get_node("%Attack"))
	return gui_attack


func loadsave(mode: int):
	var player_attack_handler: Node2D = GameState.player.attack_handler
	var player_attacks: Array[Attack] = get_attack_nodes(player_attack_handler)
	var new_attacks: Array[Attack] = []
	var gui_total_attacks = get_gui_total_attacks()
	if mode == SAVE:
		detach_nodes(player_attack_handler, player_attacks)
	for attack_index in range(num_gui_attacks):
		var attack: Attack = null
		if attack_index < len(player_attacks):
			attack = gui_total_attacks[attack_index].loadsave(mode, player_attacks[attack_index])
		else:
			attack = gui_total_attacks[attack_index].loadsave(mode, null)
		if mode == SAVE:
			new_attacks.append(attack)
	
	if mode == SAVE:
		attach_nodes(player_attack_handler, new_attacks)
	
	for total in gui_total_attacks:
		total.refresh_all()


func detach_nodes(parent, children):
	for child in children:
		parent.remove_child(child)

func attach_nodes(parent, children):
	for child in children:
		parent.add_child(child)



## i didnt ever want to have to do this
## behold my most terrible move
#func load_from_player():
#	var player_attack_handler: Node2D = GameState.player.attack_handler
#	var player_attacks: Array[Attack] = get_attack_nodes(player_attack_handler)
#	var player_attack_count: int = len(player_attacks)
#
#	for attack_index in range(4):
#		var total_node: Control = get_node("%TotalAttack"+str(attack_index+1))
#		var gui_attack_node: Control = total_node.get_node("%Attack")
#
#		if attack_index >= player_attack_count:
#			continue
#
#		var player_attack_node: Attack = player_attacks[attack_index]
#		var player_attack_upgrades: Array[Upgrade] = get_upgrade_nodes(player_attack_node)
#		var attack_upgrade_count: int = len(player_attack_upgrades)
#		gui_attack_node.referenced_node = player_attack_node
#		gui_attack_node.refresh()
#
#		for config_index in range(4):
#			var config_node: TextureButton = total_node.get_node(config_node_names[config_index])
#
#			var update_player_attack = func(): player_attack_node.control_mode = control_modes[config_index]
#			config_node.pressed.connect(update_player_attack)
#
#		for upgrade_index in range(5):
#			var upgrade_path: String = "%Upgrade" + str(upgrade_index+1)
#			var gui_upgrade_node: Control = total_node.get_node(upgrade_path)
#
#			if upgrade_index >= attack_upgrade_count:
#				gui_upgrade_node.referenced_node = null
#				continue
#
#			var player_upgrade_node: Upgrade = player_attack_upgrades[upgrade_index]
#			gui_upgrade_node.referenced_node = player_upgrade_node
#			gui_upgrade_node.refresh()
#
#
## T O T A L C O D E D U P L I C A T I O N
#func save_to_player():
#	var offset_bad_solution: int = 0
#	var player_attack_handler: Node2D = GameState.player.attack_handler
#	var player_attacks: Array[Attack] = get_attack_nodes(player_attack_handler)
#
#	for attack in player_attacks:
#		player_attack_handler.remove_child(attack)
#
#	for attack_index in range(4):
#		var total_node: Control = get_node("%TotalAttack"+str(attack_index+1))
#		var gui_attack_node: ShopDraggable = total_node.get_node("%Attack")
#		assert(gui_attack_node.slot_type == ShopDraggable.SLOT_TYPE.ATTACK)
#		var gui_attack: Attack = gui_attack_node.referenced_node
#
#		if not gui_attack:
#			offset_bad_solution += 1
#			continue
#
#		player_attack_handler.add_child(gui_attack)
#
#		var player_attack_node: Attack = player_attacks[attack_index - offset_bad_solution]
#		var player_attack_upgrades: Array[Upgrade] = get_upgrade_nodes(player_attack_node)
#		for upgrade in player_attack_upgrades:
#			player_attack_node.remove_child(upgrade)
#
#		for upgrade_index in range(5):
#			var upgrade_path: String = "%Upgrade" + str(upgrade_index+1)
#			var gui_upgrade_node: ShopDraggable = total_node.get_node(upgrade_path)
#			assert(gui_upgrade_node.slot_type == ShopDraggable.SLOT_TYPE.UPGRADE)
#			var gui_upgrade = gui_upgrade_node.referenced_node
#
#			if not gui_upgrade:
#				continue
#
#			player_attack_node.add_child(gui_upgrade)
#
#	player_attack_handler.refresh_all_attacks()


func populate_shop(shop_items):
	shop_items.shuffle()
	for index in range(4):
		var shop_node = get_node("%Shop" + str(index+1))
		shop_node.referenced_node = shop_items[index]
		shop_node.refresh()
	print("Shop contains: ", shop_items)


func open_shop(chosen_upgrades, weapon):
	loadsave(LOAD)
	populate_shop(chosen_upgrades)


func _on_shop_exit_pressed():
	close_shop()

func close_shop():
	loadsave(SAVE)
	GameState.unpause_game()
	set_visible(false)
	remove_shop.emit(shop_attached_to)


func _on_shop_item_taken():
	for i in range(1,5):
		get_node("%Shop"+str(i)).disabled = true
