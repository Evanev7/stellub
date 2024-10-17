extends CanvasLayer

@export var arrow_scene: PackedScene

@export var width_ratio: float = 2
@export var screen_height_ratio: float = 0.7
@export var margin: int = 100

var screen_size
var screen_centre
var distance
var arrows: Array


func add_target(node: Node2D):
	var arrow = arrow_scene.instantiate()
	arrow.name = "Arrow " + str(len(arrows)+1)
	arrow.node = node
	arrow.width_ratio = width_ratio
	arrow.screen_height_ratio = screen_height_ratio
	arrow.margin = margin

	if node.name == "teleporter":
		arrow.get_node("Arrow").modulate = Color(8, 7, 0)

	arrows.append(arrow)
	add_child(arrow)


func delete_target(node: Node2D):
	for arrow in arrows:
		if arrow.node == node:
			arrows.erase(arrow)
			arrow.queue_free()
