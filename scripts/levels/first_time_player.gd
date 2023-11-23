extends CanvasLayer

@onready var top_label = $TopLabel
@onready var middle_label = $MiddleLabel
@onready var bottom_label = $BottomLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.current_area = GameState.CURRENT_AREA.FIRST_TIME
	$AudioStreamPlayer.play()
	$Timer.start()

func _on_timer_timeout():
	var tween: Tween = create_tween()
	tween.tween_property(top_label, "self_modulate:a", 1, 3)
	tween.tween_callback(middle)

func middle():
	var tween: Tween = create_tween()
	tween.tween_property(middle_label, "self_modulate:a", 1, 3)
	tween.tween_callback(bottom)

func bottom():
	var tween: Tween = create_tween()
	tween.tween_property(bottom_label, "self_modulate:a", 1, 3)
	tween.tween_callback(fade_out)
	
func fade_out():
	var tween: Tween = create_tween()
	var tween2: Tween = create_tween()
	var tween3: Tween = create_tween()
	tween.tween_property(top_label, "self_modulate:a", 0, 1)
	tween2.tween_property(middle_label, "self_modulate:a", 0, 3)
	tween3.tween_property(bottom_label, "self_modulate:a", 0, 1)
	tween2.tween_callback(start_game)
	
func start_game():
	var hell_area_node = GameState.hell_area_to_instantiate.instantiate()
	get_tree().root.add_child(hell_area_node)
	var tween: Tween = create_tween()
	tween.tween_property($TextureRect, "self_modulate:a", 0, 3)
	tween.tween_callback(free_self)
	
func free_self():
	get_node("/root/first_time_player").queue_free()
