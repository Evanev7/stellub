extends VBoxContainer

@onready var num_inventory_slots: int = GameState.player.num_inventory_slots

func _ready():
	for index in range(1,num_inventory_slots+1):
		get_node("%Inventory"+str(index)).inventory_location = "Inventory%s" % index

func _on_hidden() -> void:
	if not is_node_ready():
		return
	for draggable in get_tree().get_nodes_in_group("draggable"):
		draggable.save_self()
	GameState.player.load_inventory()


func _on_draw() -> void:
	if not is_node_ready():
		return
	for draggable in get_tree().get_nodes_in_group("draggable"):
		draggable.load_self()
