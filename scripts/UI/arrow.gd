extends CanvasLayer

var node: Node2D

var width_ratio
var screen_height_ratio
var margin
var screen_size = Vector2(1920,1080)
var screen_centre = Vector2(960, 540)
var scaled: bool

func _ready():
	scaled = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var direction = node.position - GameState.player.position
	var distance = direction.length()
	rotation = direction.angle()
	if scaled:
		scale = Vector2(clamp(1000/distance, 0.3, 1), clamp(1000/distance, 0.3, 1))
	else:
		var tween: Tween = create_tween()
		scale = Vector2(1.5, 1.5)
		tween.tween_property(self, "scale", \
		Vector2(clamp(1000/distance, 0.3, 1), clamp(1000/distance, 0.3, 1)), 1.5) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_callback(func(): scaled = true)
	direction.x /= width_ratio
	direction = direction.normalized()
	direction.x *= width_ratio
	direction *= screen_height_ratio * screen_size.y/2 
	offset = screen_centre + direction
	if node.visible and direction.length() <= distance - margin:
		show()
	else:
		hide()
