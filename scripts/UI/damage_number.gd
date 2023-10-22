extends Node2D
class_name DamageNumber

@onready var label: Label = $LabelContainer/Label
@onready var label_container: Node2D = $LabelContainer
@onready var ap: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_values_and_animate(value: float, start_pos: Vector2, height:float, spread:float) -> void:
	label.text = str(round(value * 10))
	ap.play("rise_and_fade")
	
	var tween = get_tree().create_tween()
	var end_pos = Vector2(randf_range(-spread, spread), -height) + start_pos
	var tween_length = ap.get_animation("rise_and_fade").length
	
	tween.tween_property(label_container, "position", end_pos, tween_length).from(start_pos)
	
func remove() -> void:
	ap.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
