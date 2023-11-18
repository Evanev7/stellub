extends CanvasLayer


signal remove_shop

enum {SAVE, LOAD}

@export var num_gui_attacks = 3
@export var num_shop_nodes = 4

var shop_attached_to

func _ready():
	GameState.shop_HUD = self

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

func _make_custom_tooltip(for_text):
	var tooltip = preload("res://scenes/UI/Tooltip.tscn").instantiate()
	print("Huh??")
	tooltip.get_node("CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/UpgradeName").text = for_text
	return tooltip

func detach_nodes(parent, children):
	for child in children:
		parent.remove_child(child)

func attach_nodes(parent, children):
	for child in children:
		parent.add_child(child)


func populate_shop(shop_items):
	for index in range(num_shop_nodes):
		var shop_node = get_node("%Shop" + str(index+1))
		shop_node.referenced_node = shop_items[index]
		shop_node.refresh()
	print("Shop contains: ", shop_items)


func clear_shop():
	for index in range(num_shop_nodes):
		var shop_node = get_node("%Shop" + str(index+1))
		if shop_node.referenced_node:
			shop_node.referenced_node.queue_free()


func open_shop(chosen_upgrades, _weapon):
	print(chosen_upgrades)
	loadsave(LOAD)
	populate_shop(chosen_upgrades)


func _on_shop_exit_pressed():
	close_shop()

func close_shop():
	loadsave(SAVE)
	clear_shop()
	GameState.unpause_game()
	set_visible(false)
	remove_shop.emit(shop_attached_to)


func _on_shop_item_taken():
	for i in range(num_shop_nodes):
		get_node("%Shop"+str(i+1)).disabled = true
