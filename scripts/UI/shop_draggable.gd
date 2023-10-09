extends TextureButton
class_name ShopDraggable

enum SLOT_TYPE {ATTACK, UPGRADE}

@export var drag_preview_scene: PackedScene = preload("res://scenes/UI/drag_preview.tscn")
@export var slot_type: SLOT_TYPE = SLOT_TYPE.UPGRADE
@export var swappable: bool = true
@export var object_scene: PackedScene

func _ready():
	add_to_group("draggable")


func refresh_textures():
	pass


func _get_drag_data(_pos: Vector2) -> Variant:
	var data = {
		"origin_node" = self,
		"origin_scene" = object_scene,
		"slot_type" = SLOT_TYPE.UPGRADE,
		"slot_swappable" = swappable
	}
	
	print("getting")
	
	var drag_preview: Sprite2D = drag_preview_scene.instantiate()
	drag_preview.texture = texture_normal
	drag_preview.apply_scale(Vector2(64.0/texture_normal.get_width(),64.0/texture_normal.get_height()))
	add_child(drag_preview)
	
	return data
	

func _can_drop_data(_pos: Vector2, incoming_data) -> bool: 
	if slot_type != incoming_data["slot_type"]:
		return false
	if incoming_data["slot_swappable"] == false and object_scene == null:
		return false
	
	return true


func _drop_data(_pos: Vector2, data) -> void:
	print("dropping")
	if swappable and data["slot_swappable"]:
		data["origin_node"].object_scene = object_scene
		object_scene = data["origin_scene"]
	else:
		data["origin_node"].object_scene = null
		object_scene = data["origin_scene"]
	
	refresh_textures()
