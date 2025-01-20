extends MarginContainer
class_name TotalAttack

@onready var num_gui_upgrades: int = GameState.player.num_gui_upgrades
@export var control_mode: Attack.CONTROL_MODE = Attack.CONTROL_MODE.PASSIVE

@export var lmb_texture: CompressedTexture2D = preload("res://art/UI/Mouse_Left_Key_Dark.png")
@export var rmb_texture: CompressedTexture2D = preload("res://art/UI/Mouse_Right_Key_Dark.png")
@export var nmb_texture: CompressedTexture2D = preload("res://art/UI/Mouse_Simple_Key_Dark.png")

enum {SAVE, LOAD}
@onready var attack_id = get_own_index()

func _ready():
	%Attack.inventory_location = "Attack%s" % str(attack_id)
	for index in range(1,num_gui_upgrades+1):
		get_node("%Upgrade" + str(index)).inventory_location = "Attack%s:Upgrade%s" % [str(attack_id), str(index)]

func get_own_index() -> int:
	var count = 1
	for child in get_parent().get_children():
		if child == self:
			return count
		if child is TotalAttack:
			count += 1
	assert(false, "Self  not found in parents children!!")
	# Godot isn't smart enough to realise that this can never occur.
	return -1

func update_control_texture():
	var gui_control_node: TextureButton = get_node("%ControlMode")
	if control_mode == Attack.CONTROL_MODE.PRIMARY:
		gui_control_node.texture_normal = lmb_texture
	elif control_mode == Attack.CONTROL_MODE.SECONDARY:
		gui_control_node.texture_normal = rmb_texture
	else:
		gui_control_node.texture_normal = nmb_texture

func _on_control_mode_pressed(event: InputEvent):
	if event.is_action_pressed("primary_fire"):
		if control_mode != Attack.CONTROL_MODE.PRIMARY:
			control_mode = Attack.CONTROL_MODE.PRIMARY
		else:
			control_mode = Attack.CONTROL_MODE.PASSIVE
	elif event.is_action_pressed("secondary_fire"):
		if control_mode != Attack.CONTROL_MODE.SECONDARY:
			control_mode = Attack.CONTROL_MODE.SECONDARY
		else:
			control_mode = Attack.CONTROL_MODE.PASSIVE
	
	if %Attack.referenced_node:
		(%Attack.referenced_node as Attack).control_mode = control_mode
	
	update_control_texture()


func _on_draw() -> void:
	var attack = GameState.player.inventory.get("Attack%s" % str(attack_id))
	if attack != null:
		control_mode = attack.control_mode
	update_control_texture()


func _on_hidden() -> void:
	if not is_node_ready():
		return
	var attack = GameState.player.inventory.get("Attack%s" % str(attack_id))
	if attack != null:
		attack.control_mode = control_mode
