extends TextureButton
class_name ShopDraggable

signal gray_out_shop

var button_texture = preload("res://art/UI/Shop/Button Empty.png")
var attack_indicator = preload("res://art/UI/clicky finger.png")
var upgrade_indicator = preload("res://art/UI/shooty finger.png")
@onready var indicator_type := [attack_indicator, upgrade_indicator]
@export var overlay: TextureRect
enum SLOT_TYPE {ATTACK, UPGRADE}

static var hue_shift: float = 0.66

@export var drag_preview_scene: PackedScene = preload("res://scenes/UI/drag_preview.tscn")
@export var tooltip_scene: PackedScene = preload("res://scenes/UI/Tooltip.tscn")
@export var slot_type: SLOT_TYPE = SLOT_TYPE.UPGRADE
@export var is_shop: bool = false
static var shop_item_taken
static var shop_nodes = []
var referenced_node: Node

func _ready():
	if get_node_or_null("AnimationPlayer"):
		$AnimationPlayer.set_speed_scale(randf_range(2.5, 4))
	if is_shop and self not in shop_nodes:
		shop_nodes.append(self)
	add_to_group("draggable")

func refresh() -> void:
	for node in shop_nodes:
		if not node:
			shop_nodes.erase(node)
	if shop_item_taken and is_shop:
		for node in shop_nodes:
			node.modulate = Color(0.6,0.6,0.6,1)
	elif is_shop:
		for node in shop_nodes:
			node.modulate = Color(1,1,1,1)
	if referenced_node:
		if referenced_node is Upgrade:
			slot_type = SLOT_TYPE.UPGRADE
			tooltip_text = referenced_node.description
		
		elif referenced_node is Attack:
			slot_type = SLOT_TYPE.ATTACK
			tooltip_text = referenced_node.description
			if overlay != null:
				overlay.visible = true
		
		if referenced_node.get("icon") != null:
			if referenced_node.icon is CompressedTexture2D:
				texture_normal = referenced_node.icon
			elif referenced_node.icon is SpriteFrames:
				var anim_length: int = referenced_node.icon.get_frame_count("default")
				texture_normal = AnimatedTexture.new()
				texture_normal.frames = anim_length
				texture_normal.speed_scale = 8
				for frame in anim_length:
					texture_normal.set_frame_texture(frame, referenced_node.icon.get_frame_texture("default", frame))
		else:
			texture_normal = null
		
	else:
		texture_normal = null
	
	if not material:
		return
	
	match slot_type:
		SLOT_TYPE.ATTACK:
			material.set_shader_parameter("hsl_offset", [hue_shift,0,0])
		SLOT_TYPE.UPGRADE:
			material.set_shader_parameter("hsl_offset", [0,0,0])

func _get_drag_data(_pos: Vector2) -> Variant:
	var data = {
		"origin_node" = self,
		"referenced_node" = referenced_node,
		"slot_type" = slot_type,
		"is_shop" = is_shop
	}
	
	SoundManager.select.play()
	
	if not referenced_node:
		return {}
	if shop_item_taken and is_shop:
		return {}
	
	var drag_preview: Sprite2D = drag_preview_scene.instantiate()
	drag_preview.texture = texture_normal
	drag_preview.apply_scale(Vector2(64.0/texture_normal.get_width(),64.0/texture_normal.get_height()))
	drag_preview.set_rotation(0.2)
	owner.add_child(drag_preview)
	
	return data


func _can_drop_data(_pos: Vector2, incoming_data) -> bool: 
	if incoming_data == {}:
		return false
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
		shop_item_taken = true
		gray_out_shop.emit()
	
	SoundManager.place_upgrade.play()
	refresh()
	data["origin_node"].refresh()

func _make_custom_tooltip(for_text):
	var tooltip = tooltip_scene.instantiate()
	tooltip.get_node("MarginContainer/MarginContainer/VBoxContainer/Desc").text = for_text
	tooltip.get_node("MarginContainer/MarginContainer/VBoxContainer/Title").text = referenced_node.name
	tooltip.get_node("MarginContainer/TypeMargin/TypeIndicator").texture = indicator_type[slot_type]
	return tooltip

static func shop_freed():
	shop_item_taken = false
