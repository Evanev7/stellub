extends MarginContainer

static var config_node_names = [
	"%Primary", "%Secondary", "%Tertiary", "%Passive"]
static var control_modes = [
	Attack.CONTROL_MODE.PRIMARY, Attack.CONTROL_MODE.SECONDARY, Attack.CONTROL_MODE.TERTIARY, Attack.CONTROL_MODE.PASSIVE]

@export var num_gui_upgrades = 8

enum {SAVE, LOAD}


func get_upgrade_nodes(attack_node) -> Array[Upgrade]:
	var upgrades: Array[Upgrade] = []
	for upgrade in attack_node.get_children():
		if upgrade is Upgrade and upgrade.skip == false:
			upgrades.append(upgrade)
	return upgrades


func get_gui_upgrades() -> Array[Control]:
	var gui_upgrades: Array[Control] = []
	for upgrade_index in range(num_gui_upgrades):
		gui_upgrades.append(get_node("%Upgrade"+str(upgrade_index+1)))
	return gui_upgrades

func reattach_nodes(parent, children):
	# print(name, " is Reattaching ", children, " to ", parent)
	for child in children:
		if child.get_parent():
			child.get_parent().remove_child(child)
	for child in children:
		parent.add_child(child)

func detach_nodes(parent, children):
	for child in children:
		parent.remove_child(child)

func attach_nodes(parent, children):
	for child in children:
		parent.add_child(child)


func loadsave(mode: int, attack_node: Attack) -> Attack:
	var gui_attack_node = get_node("%Attack")
	var gui_upgrades: Array[Control] = get_gui_upgrades()
	var player_upgrades: Array[Upgrade] = []
	
	if mode == LOAD:
		gui_attack_node.referenced_node = attack_node
		if attack_node:
			player_upgrades = get_upgrade_nodes(attack_node)
	
	gui_attack_node.refresh()
	
	for config_index in range(4):
		var config_node: TextureButton = get_node(config_node_names[config_index])
		var update_player_attack = func(): attack_node.control_mode = control_modes[config_index]
		config_node.pressed.connect(update_player_attack)
	
	for upgrade_index in range(num_gui_upgrades):
		if mode == LOAD:
			if upgrade_index >= len(player_upgrades):
				gui_upgrades[upgrade_index].referenced_node = null
				continue
			else:
				gui_upgrades[upgrade_index].referenced_node = player_upgrades[upgrade_index]
		if mode == SAVE:
			if gui_upgrades[upgrade_index].referenced_node != null:
				player_upgrades.append(gui_upgrades[upgrade_index].referenced_node)
		gui_upgrades[upgrade_index].refresh()
	
	if mode == SAVE:
		if $%Attack.referenced_node != null:
			attack_node = $%Attack.referenced_node
		if attack_node:
			reattach_nodes(attack_node, player_upgrades)
			attack_node.refresh_bullet_resource()
	
	return attack_node
	

func refresh_all():
	$%Attack.refresh()
	for i in range(num_gui_upgrades):
		get_node("%Upgrade"+str(i+1)).refresh()
