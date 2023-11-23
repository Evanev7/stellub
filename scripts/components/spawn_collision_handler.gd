extends Node
class_name SpawnCollisionHandler

signal safe_landing_found
signal safe_landing_not_found

@export var spawn_collider: Area2D
@export var land_on_ready: bool = true
@export var on_ready_variance: Vector2 = Vector2(200,200)
@export var on_ready_attempts: int = 100
@export var disable_after_land: bool = true
@export var remove_obstruction: bool = false
@export var clear_on_bad_landing: bool = true

func _ready():
	if not spawn_collider:
		spawn_collider = Area2D.new()
		var circle = CircleShape2D.new()
		var collider = CollisionShape2D.new()
		circle.radius = 100
		collider.shape = circle
		spawn_collider.add_child(collider)
		add_child(spawn_collider)
	await get_tree().physics_frame
	if land_on_ready:
		find_safe_landing(on_ready_variance, on_ready_attempts)
	if remove_obstruction:
		remove_obstructions()

func find_safe_landing(variance:= on_ready_variance, attempts:= on_ready_attempts) -> void:
	enable_spawn_collider()
	for i in range(attempts):
		await get_tree().physics_frame
		await get_tree().physics_frame
		var safe_landing = true
		for area in spawn_collider.get_overlapping_areas():
			if area.owner != owner:
				safe_landing = false
		if safe_landing:
			safe_landing_found.emit()
			if disable_after_land: disable_spawn_collider()
			return 
		
		owner.position += Vector2(
			randf_range(-variance.x, variance.x),
			randf_range(-variance.y, variance.y)
		)
	
	safe_landing_not_found.emit()
	if disable_after_land: disable_spawn_collider()
	if clear_on_bad_landing:
		owner.queue_free()

func remove_obstructions(variance:= on_ready_variance, attempts:= on_ready_attempts):
	for i in range(attempts):
		await get_tree().physics_frame
		await get_tree().physics_frame
		for area in spawn_collider.get_overlapping_areas():
			if not area.is_in_group("magic_circle"):
				var aosch = area.owner.get_node("SpawnCollisionHandler")
				if aosch:
					aosch.find_safe_landing()

func disable_spawn_collider():
	spawn_collider.monitoring = false

func enable_spawn_collider():
	spawn_collider.monitoring = true
