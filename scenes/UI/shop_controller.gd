extends CanvasLayer



func load_from_player():
	var player_attack_handler: Node2D = GameState.player.attack_handler
	var player_attacks: Array[Node] = player_attack_handler.get_children()
	var player_attack_count: int = player_attack_handler.get_child_count()
	
	for attack_index in range(4):
		var total_node: Control = get_node("%TotalAttack"+str(attack_index))
		var gui_attack_node: Control = get_node("%Attack"+str(attack_index))
		var player_attack_node: Attack = player_attacks[attack_index]
		var player_attack_upgrades: Array[Node] = player_attack_node.get_children()
		var attack_upgrade_count: int = player_attack_node.get_child_count()
		
		if attack_index >= player_attack_count:
			total_node.visible = false
			continue
		
		gui_attack_node.referenced_node = player_attack_node
		
		for upgrade_index in range(4):
			var upgrade_path: String = "%Upgrade"+str(attack_index) + str(upgrade_index)
			var gui_upgrade_node: Control = get_node(upgrade_path)
			var player_upgrade_node: Upgrade = player_attack_upgrades[upgrade_index]
			
			if upgrade_index >= attack_upgrade_count:
				gui_upgrade_node.referenced_node = null
				continue
			
			gui_upgrade_node.referenced_node = player_upgrade_node


func sort_children(parent: Node, child_list: Array[Node]):
	for index in range(len(child_list)):
		parent.move_child(child_list[index], index)
