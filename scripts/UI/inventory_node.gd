extends VBoxContainer

@onready var num_inventory_slots: int = GameState.player.num_inventory_slots

func _ready():
    for index in range(1,num_inventory_slots+1):
        get_node("%Inventory"+str(index)).inventory_location = "Inventory%s" % index

func _on_visibility_changed() -> void:
    if not is_node_ready():
        return
    for node in get_tree().get_nodes_in_group("draggable"):
        node.refresh()
    GameState.player.load_inventory()
