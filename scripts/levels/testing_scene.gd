extends Node


#@export var heaven_area_scene: PackedScene

@export var enemy_resource_list: Array[EnemyResource]

@export var enemy_handler: EnemyHandler
@export var attack_handler: AttackHandler
@export var attack: Attack

@onready var HUD = $HUD

@onready var player = GameState.player

@export var attacks_list: Array[BulletResource]
@export var upgrades_list: Array[UpgradeResource]
@export var enemies_list: Array[EnemyResource]

enum MODE {ENEMY, ATTACK, UPGRADE}
@export var mode: MODE = MODE.UPGRADE
var index

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_handler.attack_direction.toward(attack_handler.position, $YSort/EnemyPosition.position)
	GameState.current_area = GameState.CURRENT_AREA.TESTING
	start_game()
	$LogicComponents/TerrainGenerator.generate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _unhandled_input(event):
	if event.is_action_pressed("debug_confirm"):
		match mode:
			MODE.UPGRADE:
				if index < len(upgrades_list):
					index += 1
				attack.remove_upgrades()
				attack.add_child(ShopHandler.upgrade_from_res(upgrades_list[index]))
				attack.refresh_bullet_resource()


# Start the timers we need, instantiate the HUD and get the player in the right spot.
func start_game():
	player.start()
	player.position = $YSort/PlayerStart.position
	HUD.show_health(player.hp, player.hp_max)
	HUD.show_score(player.score, player.level_threshold[player.current_level])
	

func _on_player_player_death():
	GameState.game_over.emit()


func _on_hud_start_game():
	start_game()


func _on_player_hp_changed(hp):
	HUD.show_health(hp, player.hp_max)


func _on_player_level_up(current_level):
	HUD.change_min_XP(player.level_threshold[player.current_level])
	HUD.show_health(player.hp, player.hp_max)




