extends VBoxContainer

@export var num_gui_attacks: int = 3

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
