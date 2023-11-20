extends TextureButton
class_name ShopDraggable

signal shop_item_taken

var button_texture = preload("res://art/UI/Shop/Button Empty.png")
enum SLOT_TYPE {ATTACK, UPGRADE}

@export var drag_preview_scene: PackedScene = preload("res://scenes/UI/drag_preview.tscn")
@export var tooltip_scene: PackedScene = preload("res://scenes/UI/Tooltip.tscn")
@export var slot_type: SLOT_TYPE = SLOT_TYPE.UPGRADE
@export var is_shop: bool = false
var referenced_node: Node

func _ready():
	add_to_group("draggable")

func refresh() -> void:
	if referenced_node:
		if referenced_node is Upgrade:
			slot_type = SLOT_TYPE.UPGRADE
			tooltip_text = referenced_node.description
		
		elif referenced_node is Attack:
			slot_type = SLOT_TYPE.ATTACK
	
		if referenced_node.get("icon") != null:
			texture_normal = referenced_node.icon
		else:
			texture_normal = button_texture
	else:
		texture_normal = button_texture

func _get_drag_data(_pos: Vector2) -> Variant:
	var data = {
		"origin_node" = self,
		"referenced_node" = referenced_node,
		"slot_type" = slot_type,
		"is_shop" = is_shop
	}
	
	print("Drag Data: ", data)
	
	if not referenced_node:
		return data
	
	var drag_preview: Sprite2D = drag_preview_scene.instantiate()
	drag_preview.texture = texture_normal
	drag_preview.apply_scale(Vector2(64.0/texture_normal.get_width(),64.0/texture_normal.get_height()))
	drag_preview.set_rotation(0.2)
	owner.add_child(drag_preview)
	
	return data


func _can_drop_data(_pos: Vector2, incoming_data) -> bool: 
	if incoming_data["referenced_node"] == null:
		return false
	if slot_type != incoming_data["slot_type"]:
		return false
	if is_shop:
		return false
	return true


func _drop_data(_pos: Vector2, data) -> void:
	data["origin_node"].referenced_node = referenced_node
	referenced_node = data["referenced_node"]
	if data["is_shop"]:
		shop_item_taken.emit()
	
	refresh()
	data["origin_node"].refresh()

func _make_custom_tooltip(for_text):
	var tooltip = tooltip_scene.instantiate()
	tooltip.get_node("MarginContainer/MarginContainer/Desc").text = for_text
	return tooltip
