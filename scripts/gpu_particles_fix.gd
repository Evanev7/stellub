extends GPUParticles2D

func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			interpolate = false
			process_material.turbulence_enabled = false
		NOTIFICATION_UNPAUSED:
			interpolate = true
			process_material.turbulence_enabled = true
