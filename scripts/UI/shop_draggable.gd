extends TextureButton
class_name ShopDraggable

static var placeholder_texture = PlaceholderTexture2D.new()
enum SLOT_TYPE {ATTACK, UPGRADE}

@export var drag_preview_scene: PackedScene = preload("res://scenes/UI/drag_preview.tscn")
@export var slot_type: SLOT_TYPE = SLOT_TYPE.UPGRADE
@export var swappable: bool = true
var referenced_node

func _ready():
	add_to_group("draggable")

func refresh() -> void:
	if referenced_node and referenced_node.get("icon") != null:
		texture_normal = referenced_node.icon
	else:
		texture_normal = placeholder_texture

func _get_drag_data(_pos: Vector2) -> Variant:
	var data = {
		"origin_node" = self,
		"referenced_node" = referenced_node,
		"slot_type" = slot_type,
		"slot_swappable" = swappable
	}
	
	var drag_preview: Sprite2D = drag_preview_scene.instantiate()
	drag_preview.texture = texture_normal
	drag_preview.apply_scale(Vector2(64.0/texture_normal.get_width(),64.0/texture_normal.get_height()))
	add_child(drag_preview)
	
	return data
	

func _can_drop_data(_pos: Vector2, incoming_data) -> bool: 
	if slot_type != incoming_data["slot_type"]:
		return false
	if incoming_data["slot_swappable"] == false and referenced_node == null:
		return false
	
	return true


func _drop_data(_pos: Vector2, data) -> void:
	if slot_type != data["slot_type"]:
		return
	
	if swappable and data["slot_swappable"]:
		data["origin_node"].referenced_node = referenced_node
		referenced_node = data["referenced_node"]
	else:
		data["origin_node"].referenced_node = null
		referenced_node = data["referenced_node"]
	
	refresh()
	data["origin_node"].refresh()
