extends EnemyBehaviour

signal give_me_data(who)
signal boss_health_changed(new_hp, max_hp)

@export var finite_state_machine: Node
@export var boss_upgrade: UpgradeResource
@onready var flap = $flap

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
	
	attack_handler.upgrade_all_attacks(boss_upgrade)
	
	for attack in attack_handler.get_children():
		if attack.name == "Fire":
			attack_handler.remove_child(attack)
		for upgrade in attack.get_children():
			if upgrade.type == Upgrade.TYPE.STAT:
				attack.remove_child(upgrade)
		
		
	attack_handler.passive_all_attacks()
	attack_handler.aim_attacks_at_player()
	attack_handler.refresh_all_attacks()
	
	
	await get_tree().create_timer(1.5).timeout
	
	
	await get_tree().create_timer(4.0).timeout
	GameState.player.camera_2d.boss = self


func _physics_process(_delta):
	move_and_slide()
	if !flap.playing:
		flap.play()

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
