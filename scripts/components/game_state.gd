extends Node

signal fire_bullet(origin, bullet: BulletResource, init: FireFrom)
signal spawn_enemy
signal game_over
signal register_enemy

var _save: SaveGame

var debug: bool = true

var player: CharacterBody2D
var pause_menu: CanvasLayer
var shop_HUD: CanvasLayer


enum CURRENT_AREA {HELL, HEAVEN, MAIN_MENU, FIRST_TIME, BOSS, TESTING}
var current_area
var current_area_node

var area_scenes = {
	CURRENT_AREA.HELL: preload("res://scenes/levels/hell_area.tscn"),
	CURRENT_AREA.HEAVEN: preload("res://scenes/levels/heaven_area.tscn"),
	CURRENT_AREA.MAIN_MENU: preload("res://scenes/levels/menu.tscn"),
	CURRENT_AREA.FIRST_TIME: preload("res://scenes/levels/first_time_player.tscn"),
	CURRENT_AREA.BOSS: preload("res://scenes/levels/boss_area.tscn"),
}


@onready var clicky_hand = preload("res://art/UI/clicky finger.png")
@onready var shooty_hand = preload("res://art/UI/shooty finger.png")

var num_enemies: int = 0
var num_bullets: int = 0
var num_xp_pickups: int = 0
var num_damage_labels: int = 0

## SETTINGS
var player_data = PlayerData: set = set_stats

## STATS
var enemies_killed: int = 0
var souls_collected: float = 0
var bullets_summoned: int = 0
var damage_dealt: float = 0
var circles_completed: int = 0


func _ready():
	Input.set_custom_mouse_cursor(clicky_hand, Input.CURSOR_POINTING_HAND, Vector2i(8,5))
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_over.connect(queue_free_groups)
	current_area_node = get_parent().get_node("menu")
	create_or_load_save()
	
func set_stats(new_stats: PlayerData):
	player_data = new_stats
	
func load_area(area: CURRENT_AREA):
	var area_node = area_scenes[area].instantiate()
	
	if area_node.has_node("YSort") and current_area_node.has_node("YSort"):
		player.get_parent().remove_child(player)
		area_node.get_node("YSort").add_child(player)
		
	current_area_node.queue_free()
	
	current_area = area
	current_area_node = area_node
	
	get_parent().add_child(area_node)
	


func reset_statistics():
	Input.set_custom_mouse_cursor(shooty_hand, Input.CURSOR_ARROW, Vector2i(32,32))
	enemies_killed = 0
	souls_collected = 0
	bullets_summoned = 0
	damage_dealt = 0
	circles_completed = 1
	
func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		if current_area == CURRENT_AREA.MAIN_MENU or current_area == CURRENT_AREA.FIRST_TIME:
			get_tree().quit()
		else:
			if shop_HUD.visible == false:
				if get_tree().paused == false:
					pause_menu._on_hud_open_pause_menu()
				else:
					if pause_menu.options_menu.visible:
						pause_menu.options_menu.go_back.emit()
					else:
						pause_menu._on_continue_pressed()
			else:
				shop_HUD.close_shop()
	
	
	##Debug ###############################
	if not debug:
		return
	if Input.is_action_pressed("debug_gain_score"): ## R
		player.gain_score(100)
		current_area_node.get_node("HUD").show_score(player.score, player.level_threshold[player.current_level])
	
	if Input.is_action_just_pressed("debug_evolve"): ## E
		player.evolve()
	
	if Input.is_action_just_pressed("debug_spawn_enemy"): # L
		for i in range(10):
			current_area_node.get_node("LogicComponents/EnemyHandler").spawn_enemy(randi() % 7)
		
	if Input.is_action_just_pressed("debug_spawn_boss"): # B
		player.send_loadout_to_boss()
		
	if Input.is_action_just_pressed("debug_activate_teleporter"): # T
		current_area_node.get_node("LogicComponents/ShopHandler")._on_activate_teleporter()
		
	if Input.is_action_just_pressed("debug_print_data"): # P
		current_area_node.get_node("HUD").show_debug()
		
	if Input.is_action_just_pressed("debug_spawn_shop"): # F
		current_area_node.get_node("LogicComponents/ShopHandler")._on_spawn_shop(player.global_position)
	
	if Input.is_action_just_pressed("debug_enter_final_boss"): # G
		if current_area != CURRENT_AREA.BOSS:
			load_area(CURRENT_AREA.BOSS)
		else:
			current_area_node.get_node("YSort/angel_boss").health -= 100
		
	#######################################

func pause_game():
	Input.set_custom_mouse_cursor(clicky_hand, Input.CURSOR_ARROW, Vector2i(8,5))
	get_tree().paused = true

func unpause_game():
	Input.set_custom_mouse_cursor(shooty_hand, Input.CURSOR_ARROW, Vector2i(32,32))
	get_tree().paused = false


func queue_free_groups():
	get_tree().call_group("enemy", "remove")
	get_tree().call_group("bullet", "remove")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("shop", "queue_free")
	get_tree().call_group("boss", "queue_free")
	get_tree().call_group("magic_circle", "remove_objective_marker")
	get_tree().call_group("magic_circle", "queue_free")


func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	var pp := node as PopupPanel
	if pp and pp.theme_type_variation == "TooltipPanel":
		pp.transparent_bg = true
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameState.save_game()
		get_tree().quit()

func create_or_load_save():
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame() as SaveGame
	else:
		_save = SaveGame.new()
		_save.write_savegame()

	player_data = _save.player_data
	
	AudioServer.set_bus_volume_db(0, linear_to_db(player_data.master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(player_data.sfx_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(player_data.music_volume))
	
func save_game():
	_save.write_savegame()
