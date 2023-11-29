extends Node2D

func _process(_delta):
	var size = get_viewport_rect().size
	global_position = GameState.player.global_position
	$GPUParticles2D.get_process_material().set_emission_box_extents(Vector3(size.x, size.y, 1))
