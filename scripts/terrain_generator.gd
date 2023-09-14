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

func _ready():
	$Timer.wait_time = update_tick_rate
	$Timer.start()


func _on_timer_timeout():
	generate()


func generate():
	var player_atlas_coords: Vector2i
	player_atlas_coords.x = floori(GameState.player.position.x/tile_size.x)
	player_atlas_coords.y = floori(GameState.player.position.y/tile_size.y)
	for x in range(-update_range.x,update_range.x+1):
		for y in range(-update_range.y,update_range.y+1):
			var update_coords = player_atlas_coords + Vector2i(x,y)
			if update_coords not in used_cells:
				populate(update_coords)
				used_cells = tile_map.get_used_cells(0)


func populate(coords):
	tile_map.set_cell(0,coords,1,Vector2i(0,0),0)
	#This could use better handling, it's finnicky right now in a bad way.
	for index in range(len(objects)):
		var poisson_coefficient = object_spawn_rate[index]
		var number = poisson(poisson_coefficient)
		for i in range(number):
			coords = Vector2(coords) * tile_size
			coords.x += randf_range(0,tile_size.x)
			coords.y += randf_range(0,tile_size.y)
			var object = objects[index].instantiate()
			object.position = coords
			ysorter.add_child(object)


func poisson(lambda):
	var total = 0
	var result = -1
	while total < 1:
		total += -1/lambda * log(randf())
		result += 1
	return result
