extends Node

@export var tile_map: TileMap 
@export var ysorter: Node2D
@export var update_range: Vector2i


#This could use better handling down the line but it'll do
#What to generate
@export var objects: Array[PackedScene]
#How often to generate it
@export var object_spawn_rate: Array[float]

@onready var update_tick_rate: float = 1
@onready var tile_size: Vector2 = tile_map.scale * Vector2(tile_map.tile_set.tile_size)
@onready var used_cells = tile_map.get_used_cells(0)

var landing_attempts = 10

func _ready():
	$Timer.wait_time = update_tick_rate
	$Timer.start()


func _process(_delta):
	##Debug ###############################
	
	if Input.is_key_pressed(KEY_M): ## Increase score by 10
		populate(Vector2i(0,0))
	
	#######################################


func _on_timer_timeout():
	generate()


func generate() -> void:
	var player_atlas_coords: Vector2i = Vector2i(
			floori(GameState.player.position.x/tile_size.x),
			floori(GameState.player.position.y/tile_size.y))
	
	for x in range(-update_range.x,update_range.x+1):
		for y in range(-update_range.y,update_range.y+1):
			var update_coords = player_atlas_coords + Vector2i(x,y)
			if update_coords not in used_cells:
				populate(update_coords)
				used_cells = tile_map.get_used_cells(0)


func populate(coords) -> void:
	tile_map.set_cell(0,coords,1,Vector2i(0,0),0)
	coords = Vector2(coords) * tile_size
	#This could use better handling, it's finnicky right now in a bad way.
	for index in range(len(objects)):
		var poisson_coefficient = object_spawn_rate[index]
		var number = poisson(poisson_coefficient)
		for i in range(number):
			var object = objects[index].instantiate()
			
			#This shouldn't be here, it's hard to find later.
			var random_size_scale = randf_range(0.9, 1.3)
			var flip_direction = randi_range(0,1)
			object.scale = Vector2(int(flip_direction)*2-1, 1) * random_size_scale
			
			coords.x += randf_range(0,tile_size.x)
			coords.y += randf_range(0,tile_size.y)
			
			object.position = coords
			
			ysorter.add_child(object)
			object.add_to_group("terrain")
			

func poisson(lambda) -> int:
	var total = 0
	var result = -1
	while total < 1:
		total += -1/lambda * log(randf())
		result += 1
	return result
