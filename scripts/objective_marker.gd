extends CanvasLayer

@export var arrow_scene: PackedScene
@export var width_ratio: float = 2
@export var screen_height_ratio: float = 0.35
@export var margin: int = 100

var screen_size
var screen_centre
var distance
var arrows: Array

func _ready():
	get_viewport().connect("size_changed",_on_screen_size_changed)
	_on_screen_size_changed()

func _process(_delta):
	for pair in arrows:
		var arrow = pair[0]
		var node = pair[1]
		var direction = node.position - GameState.player.position
		distance = direction.length()
		arrow.rotation = direction.angle()
		direction.x /= width_ratio
		direction = direction.normalized()
		direction.x *= width_ratio
		direction *= screen_height_ratio * screen_size.x/2 
		arrow.offset = screen_centre + direction
		if direction.length() <= distance - margin:
			arrow.show()
		else:
			arrow.hide()

func _on_screen_size_changed():
	screen_size = get_viewport().size
	screen_centre = Vector2(screen_size / 2)


func add_target(node: Node2D):
	var arrow = arrow_scene.instantiate()
	arrows.append([arrow, node])
	add_child(arrow)


func delete_target(node: Node2D):
	var to_delete
	for pair in arrows:
		if pair[1] == node:
			to_delete = pair
	arrows.erase(to_delete)
