extends Camera2D

@export var move_speed: float = 2.0 # camera position lerp speed
@export var zoom_speed: float = 1.0  # camera zoom lerp speed
@export var min_zoom: float = 1.0  # camera won't zoom closer than this
@export var max_zoom: float = 0.4  # camera won't zoom farther than this

var zoom_target: float
var boss: CharacterBody2D = null

func _process(delta):	
	if GameState.current_area != GameState.CURRENT_AREA.BOSS:
		boss = null
		
	if boss:
		global_position = global_position.lerp(0.5 * (GameState.player.global_position + boss.global_position), move_speed * delta)
		zoom_target = clamp(600/(boss.global_position - GameState.player.position).length(), max_zoom, min_zoom)
		zoom = lerp(zoom, zoom_target * Vector2.ONE, zoom_speed * delta)

