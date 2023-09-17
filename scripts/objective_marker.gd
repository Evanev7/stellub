extends CanvasLayer

@export var arrow_target: Node2D
@export var width_ratio: float = 2
@export var screen_height_ratio: float = 0.35
@export var margin: int = 100

var screen_size
var screen_centre
var distance

func _ready():
	get_viewport().connect("size_changed",_on_screen_size_changed)
	_on_screen_size_changed()

func _process(_delta):
	if not arrow_target:
		return
	var direction = arrow_target.position - GameState.player.position
	distance = direction.length()
	rotation = direction.angle()
	direction.x /= width_ratio
	direction = direction.normalized()
	direction.x *= width_ratio
	direction *= screen_height_ratio * screen_size.x/2 
	offset = screen_centre + direction
	if direction.length() <= distance - margin:
		show()
	else:
		hide()

func _on_screen_size_changed():
	screen_size = get_viewport().size
	screen_centre = Vector2(screen_size / 2)
