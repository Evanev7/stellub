extends TextureButton
class_name ShopDraggable

signal gray_out_shop

var button_texture = preload("res://art/UI/Shop/Button Empty.png")
var attack_indicator = preload("res://art/UI/clicky finger.png")
var upgrade_indicator = preload("res://art/UI/shooty finger.png")
@export var overlay: TextureRect
enum SLOT_TYPE {ATTACK, UPGRADE, EITHER}

static var hue_shift: float = 0.66

@export var drag_preview_scene: PackedScene = preload("res://scenes/UI/drag_preview.tscn")
@export var tooltip_scene: PackedScene = preload("res://scenes/UI/Tooltip.tscn")
@export var slot_type: SLOT_TYPE = SLOT_TYPE.UPGRADE
@export var is_shop: bool = false
@onready var rune_fill: TextureRect = %RuneFill
@onready var rune_outline: TextureRect = %RuneOutline
static var shop_item_taken
static var shop_nodes = []
var referenced_node: Node
var inventory_location: String = ""

func _ready() -> void:
	if get_node_or_null("AnimationPlayer"):
		$AnimationPlayer.set_speed_scale(randf_range(2.5, 4))
	if is_shop and self not in shop_nodes:
		shop_nodes.append(self)
	add_to_group("draggable")


func refresh() -> void:
	if overlay != null:
		overlay.visible = false
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
			if material:
				material.set_shader_parameter("hsv_offset", Vector3(0., 0., 0.))
			rune_fill.visible = true
			rune_outline.visible = true
			match referenced_node.rarity:
				1:
					rune_fill.modulate = Color(0.1, 0.3, 0.1, 1)
				2:
					rune_fill.modulate = Color(0.32, 0, 0.32, 1)
				3:
					rune_fill.modulate = Color(1, 0.81, 0.41, 1)
			slot_type = SLOT_TYPE.UPGRADE
			tooltip_text = referenced_node.description

		elif referenced_node is Attack:
			if material:
				material.set_shader_parameter("hsv_offset", Vector3(2., 0., 0.05))
			rune_fill.visible = false
			rune_outline.visible = false
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
		rune_fill.visible = false
		rune_outline.visible = false
		tooltip_text = ""
	
	if not material:
		return
	
	match slot_type:
		SLOT_TYPE.ATTACK:
			material.set_shader_parameter("hsl_offset", [hue_shift,0,0])
		SLOT_TYPE.UPGRADE:
			material.set_shader_parameter("hsl_offset", [0,0,0])

func load_self() -> void:
	if inventory_location != "":
		if inventory_location in GameState.player.inventory.keys():
			referenced_node = GameState.player.inventory[inventory_location]
	refresh()

func save_self() -> void:
	# A little hacky
	if inventory_location != "" and is_visible_in_tree():
		GameState.player.inventory[inventory_location] = referenced_node

func _get_drag_data(_pos: Vector2) -> Dictionary:
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
	if referenced_node is Upgrade:
		match referenced_node.rarity:
			1:
				drag_preview.rune_colour = Color(0.1, 0.3, 0.1, 1)
			2:
				drag_preview.rune_colour = Color(0.32, 0, 0.32, 1)
			3:
				drag_preview.rune_colour = Color(1, 0.81, 0.41, 1)
	elif referenced_node is Attack:
		drag_preview.rune_colour = Color(0, 0, 0, 0)
	drag_preview.apply_scale(Vector2(64.0/texture_normal.get_width(),64.0/texture_normal.get_height()))
	drag_preview.set_rotation(0.2)
	owner.add_child(drag_preview)
	
	return data


func _can_drop_data(_pos: Vector2, incoming_data) -> bool:
	if incoming_data == {}:
		return false
	if incoming_data["referenced_node"] == null:
		return false
	if slot_type != SLOT_TYPE.EITHER and slot_type != incoming_data["slot_type"]:
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

func _make_custom_tooltip(for_text: String):
	var tooltip: CenterContainer = tooltip_scene.instantiate()
	if referenced_node != null:
		tooltip.get_node("MarginContainer/MarginContainer/VBoxContainer/Desc").text = for_text
		match slot_type:
			SLOT_TYPE.ATTACK:
				tooltip.get_node("MarginContainer/MarginContainer/VBoxContainer/Title").text = referenced_node.attack_name
				tooltip.get_node("MarginContainer/TypeMargin/TypeIndicator").texture = attack_indicator
			SLOT_TYPE.UPGRADE:
				tooltip.get_node("MarginContainer/MarginContainer/VBoxContainer/Title").text = referenced_node.upgrade_name
				tooltip.get_node("MarginContainer/TypeMargin/TypeIndicator").texture = upgrade_indicator
		return tooltip

static func shop_freed() -> void:
	shop_item_taken = false
