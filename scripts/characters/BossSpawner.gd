extends Node

@export var enemy_handler: EnemyHandler
@export var enemy_scene: PackedScene
@export var boss_resource: EnemyResource
@export var boss_start: Marker2D
@export var enemy_ysort: Node2D
@export var boss_upgrade: UpgradeResource

var boss_reference: CharacterBody2D


func _ready():
	spawn_boss()
	add_to_group("boss")
	
func spawn_boss():
	var boss = enemy_scene.instantiate()
	
#	boss.connect("spawn_shop", spawn_shop)
#	boss.connect("play_damage_sound", play_damage_sound)
#	boss.connect("play_death_sound", play_death_sound)
	boss.connect("spawn_damage_number", enemy_handler.spawn_damage_number)
	boss.connect("give_me_data", owner.heres_your_data)
	
	enemy_ysort.add_child.call_deferred(boss)
	call_deferred("set_up",boss)

func set_up(boss):
	GameState.num_enemies += 1
	boss.resource = boss_resource
	boss.resource.UNIQUE_MULTIPLIER = 1
	boss.resource.OVERALL_MULTIPLIER = 1
	boss.position = boss_start.position
	
	boss.dead = false
	boss.set_physics_process(true)
	boss.sprite.visible = true
	boss.shadow.visible = true
	boss.set_data()
	boss.collider.set_deferred("disabled", false)
	boss.hitbox_collisionshape.set_deferred("disabled", false)
	boss.hurtbox_collisionshape.set_deferred("disabled", false)
	
	
	GameState.register_enemy.emit(boss)
	
	for child in GameState.player.attack_handler.get_children():
			
		if child is Attack:
			# remove child from player except for first weapon later
			var new_attack = child.duplicate()
			boss.attack_handler.add_child(new_attack)
#		if not child == GameState.player.attack_handler.get_children()[0]:
#			child.get_parent().remove_child(child)
			
	boss.attack_handler.passive_all_attacks()
	boss.attack_handler.aim_attacks_at_player()
	boss.attack_handler.refresh_all_attacks()
	
	boss.attack_handler.upgrade_all_attacks(boss_upgrade)
	
## NEED TO ADD THESE MODIFIERS TO ALL WEAPONS
## Make it an upgrade, call it Boss Upgrade and attach it directly
#	attack.bullet = GameState.player.all_bullets[i].duplicate(true)
#	attack.bullet.deactivation_range *= 5
#	attack.bullet.bullet_range *= 5
#	attack.bullet.shot_spread *= 8
#	attack.bullet.start_range *= 2