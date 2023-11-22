extends Node

signal fire_bullet(origin, bullet: BulletResource, init: FireFrom)
signal game_over
signal register_enemy

var player: CharacterBody2D
var pause_menu: CanvasLayer
var shop_HUD: CanvasLayer

var damage_numbers_enabled: bool = true

enum CURRENT_AREA {HELL, HEAVEN, BOSS, TESTING}
var current_area
@onready var hell_area_to_instantiate: PackedScene = preload("res://scenes/levels/hell_area.tscn")
@onready var heaven_area_to_instantiate: PackedScene = preload("res://scenes/levels/heaven_area.tscn")

var num_enemies: int = 0
var num_bullets: int = 0
var num_xp_pickups: int = 0
var num_damage_labels: int = 0

var debug: bool = true


func _ready():
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_over.connect(queue_free_groups)
	
func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause") and shop_HUD.visible == false:
		if get_tree().paused == false:
			pause_menu._on_hud_open_pause_menu()
		else:
			pause_menu._on_continue_pressed()
	
	
	
	##Debug ###############################
	
	if debug and Input.is_action_pressed("debug_gain_score"): ## R
		player.gain_score(100)
		get_node("/root").get_child(1).get_node("HUD").show_score(player.score, player.level_threshold[player.current_level])
	
	if debug and Input.is_action_just_pressed("debug_evolve"): ## E
		player.current_evolution += 1
		player.evolve()
	
	if debug and Input.is_action_just_pressed("debug_spawn_enemy"): # L
		for i in range(10):
			get_node("/root").get_child(1).get_node("LogicComponents/EnemyHandler").spawn_enemy(randi() % 7)
		
	if debug and Input.is_action_just_pressed("debug_spawn_boss"): # B
		player.send_loadout_to_boss()
		
	if debug and Input.is_action_just_pressed("debug_activate_teleporter"): # T
		get_node("/root").get_child(1).get_node("LogicComponents/ShopHandler")._on_activate_teleporter()
		
	if debug and Input.is_action_just_pressed("debug_print_data"): # P
		get_node("/root").get_child(1).get_node("HUD").show_debug()
		
	#######################################

func pause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func unpause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false


func queue_free_groups():
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("shop", "queue_free")
	get_tree().call_group("boss", "queue_free")
	
	for circle in get_tree().get_nodes_in_group("magic_circle"):
		circle.call_deferred("remove_objective_marker", circle)
