extends MarginContainer

@export var num_gui_upgrades = 8
@export var control_mode: Attack.CONTROL_MODE = Attack.CONTROL_MODE.PASSIVE

@export var unpressed_texture: CompressedTexture2D
@export var pressed_texture: CompressedTexture2D

enum {SAVE, LOAD}

func _ready():
	var gui_control_node: TextureButton = get_node("%ControlMode")
	if control_mode == Attack.CONTROL_MODE.PASSIVE:
		gui_control_node.texture_normal = unpressed_texture
		gui_control_node.texture_pressed = pressed_texture
	else:
		gui_control_node.texture_normal = pressed_texture
		gui_control_node.texture_pressed = unpressed_texture
	

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
	
	if mode == SAVE and attack_node:
		print(control_mode)
		attack_node.control_mode = control_mode
		print("but ", attack_node.control_mode)
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


func _on_control_mode_pressed():
	var gui_control_node: TextureButton = get_node("%ControlMode")
	if control_mode == Attack.CONTROL_MODE.PRIMARY:
		control_mode = Attack.CONTROL_MODE.PASSIVE
		gui_control_node.texture_normal = unpressed_texture
		gui_control_node.texture_pressed = pressed_texture
	else:
		control_mode = Attack.CONTROL_MODE.PRIMARY
		gui_control_node.texture_normal = pressed_texture
		gui_control_node.texture_pressed = unpressed_texture
	
