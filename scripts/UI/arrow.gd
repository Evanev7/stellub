extends CanvasLayer

var node: Node2D

var width_ratio
var screen_height_ratio
var margin
var screen_size = Vector2(1920,1080)
var screen_centre = Vector2(960, 540)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = node.position - GameState.player.position
	var distance = direction.length()
	rotation = direction.angle()
	scale = Vector2(clamp(1000/distance, 0.3, 1), clamp(1000/distance, 0.3, 1))
	direction.x /= width_ratio
	direction = direction.normalized()
	direction.x *= width_ratio
	direction *= screen_height_ratio * screen_size.y/2 
	offset = screen_centre + direction
	if direction.length() <= distance - margin:
		show()
	else:
		hide()
