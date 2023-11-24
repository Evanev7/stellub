class_name FireFrom

var position: Vector2
var direction: Vector2

func toward(me: Vector2, you: Vector2):
	position = me
	direction = (you - me)
