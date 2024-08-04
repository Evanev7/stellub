extends EnemyBehaviour

signal give_me_data(who)
signal boss_health_changed(new_hp, max_hp)

@export var finite_state_machine: Node
@export var boss_upgrade: UpgradeResource

func _ready():
	super()
	var temp_handler = attack_handler
	attack_handler = GameState.player.attack_handler
	GameState.player.attack_handler = temp_handler
	
	attack_handler.reparent(self, false)
	GameState.player.attack_handler.reparent(GameState.player, false)
	
	for _i in range(GameState.player.current_level):
		GameState.player.attack_handler.upgrade_all_attacks(GameState.player.stat_upgrade)
	
	attack_handler.owner = self
	GameState.player.attack_handler.owner = GameState.player
	
	for child in attack_handler.get_children():
		if child.name == "Fire":
			attack_handler.remove_child(child)
	attack_handler.passive_all_attacks()
	attack_handler.aim_attacks_at_player()
	attack_handler.refresh_all_attacks()
	attack_handler.upgrade_all_attacks(boss_upgrade)
	await get_tree().create_timer(1.5).timeout
	boss_health_changed.emit(health, resource.MAX_HP*overall_multiplier*unique_multiplier)
	
	await get_tree().create_timer(4.0).timeout
	GameState.player.camera_2d.boss = self


func _physics_process(_delta):
	move_and_slide()


func hurt(area):
	super(area)
	boss_health_changed.emit(health, resource.MAX_HP*overall_multiplier*unique_multiplier)
	if dead == true:
		GameState.game_over.emit()
		GameState.player.attack_handler.stop()
		GameState.player.hide()
		GameState.player.set_physics_process(false)
		if SoundManager.currently_playing_music:
			SoundManager.currently_playing_music.volume_db -= 10
