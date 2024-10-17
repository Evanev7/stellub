extends Sprite2D

@onready var rune_fill: Sprite2D = $Sprite2D2
var rune_colour: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	print(rune_colour)
	rune_fill.self_modulate = rune_colour


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	if Input.is_action_just_released("left_mouse"):
		queue_free()
