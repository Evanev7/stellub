extends CharacterBody2D

@export var speed = 100
@onready var player = get_parent().get_node("PlayerTopDown")
@export var health : int = 10
var player_position
var target_position


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 1:
		velocity = target_position * speed
		move_and_slide()
		
	if health <= 0:
		queue_free()
		
	var angle = global_position.angle_to_point(player.global_position)
#	if abs(angle) < PI/2:
#		scale.x = -1
#	else:
#		scale.x = 1


func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet"):
		health -= 1
		scale = Vector2(0.1, 0.1)
		var tween := create_tween()
		tween.tween_property(self, "global_scale", Vector2(0.6, 0.6), 0.02)
