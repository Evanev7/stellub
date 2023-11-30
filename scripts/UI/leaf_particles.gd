extends Node2D

@onready var particle_spawner: Node2D = $ParticleSpawner
var particles: int = 1

func _process(_delta):
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()

	particle_spawner.global_position.x = top_left.x + size.x/2 
	particle_spawner.global_position.y = top_left.y - 50
	
	for child in particle_spawner.get_children():
		child.get_process_material().set_emission_box_extents(Vector3(size.x, 50, 1))
	
	if int(particle_spawner.global_position.y) < -(particles * 200):
		spawn_new_particles()
		
func spawn_new_particles():
	particle_spawner.add_child(particle_spawner.get_node("GPUParticles2D").duplicate())
	particles += 1
