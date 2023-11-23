extends Node

signal fire_bullet(origin, bullet: BulletResource, init: FireFrom)
signal game_over
signal register_enemy

var first_time: bool = true

var player: CharacterBody2D
var pause_menu: CanvasLayer
var shop_HUD: CanvasLayer

var damage_numbers_enabled: bool = true

enum CURRENT_AREA {HELL, HEAVEN, BOSS, TESTING, MAIN_MENU, FIRST_TIME}
var current_area
@onready var hell_area_to_instantiate: PackedScene = preload("res://scenes/levels/hell_area.tscn")
@onready var heaven_area_to_instantiate: PackedScene = preload("res://scenes/levels/heaven_area.tscn")


@onready var clicky_hand = load("res://art/UI/clicky finger.png")
@onready var shooty_hand = load("res://art/UI/shooty finger.png")

var num_enemies: int = 0
var num_bullets: int = 0
var num_xp_pickups: int = 0
var num_damage_labels: int = 0

var debug: bool = true

## STATS
var enemies_killed: int = 0
var souls_collected: float = 0
var bullets_summoned: int = 0
var damage_dealt: float = 0

func _ready():
	Input.set_custom_mouse_cursor(clicky_hand, Input.CURSOR_POINTING_HAND, Vector2i(8,5))
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_over.connect(queue_free_groups)
	
func reset_statistics():
	enemies_killed = 0
	souls_collected = 0
	bullets_summoned = 0
	damage_dealt = 0
	
func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		if current_area == CURRENT_AREA.MAIN_MENU or current_area == CURRENT_AREA.FIRST_TIME:
			get_tree().quit()
		else:
			if shop_HUD.visible == false:
				if get_tree().paused == false:
					pause_menu._on_hud_open_pause_menu()
				else:
					pause_menu._on_continue_pressed()
			else:
				shop_HUD.close_shop()
	
	
	
	##Debug ###############################
	
	if debug and Input.is_action_just_pressed("left_mouse") and current_area == CURRENT_AREA.FIRST_TIME:
		get_parent().get_child(1).start_game()
		
	if debug and Input.is_action_pressed("debug_gain_score"): ## R
		player.gain_score(100)
		get_node("/root").get_child(1).get_node("HUD").show_score(player.score, player.level_threshold[player.current_level])
	
	if debug and Input.is_action_just_pressed("debug_evolve"): ## E
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
	Input.set_custom_mouse_cursor(clicky_hand, 0, Vector2i(8,5))
	get_tree().paused = true

func unpause_game():
	Input.set_custom_mouse_cursor(shooty_hand, 0, Vector2i(16,16))
	get_tree().paused = false


func queue_free_groups():
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("shop", "queue_free")
	get_tree().call_group("boss", "queue_free")
	
	for circle in get_tree().get_nodes_in_group("magic_circle"):
		circle.call_deferred("remove_objective_marker", circle)
