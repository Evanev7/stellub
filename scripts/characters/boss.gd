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
	var enemy = enemy_scene.instantiate()
	enemy_ysort.add_child(enemy)
	GameState.num_enemies += 1
	enemy.resource = boss_resource
	enemy.resource.UNIQUE_MULTIPLIER = 1
	enemy.resource.OVERALL_MULTIPLIER = 1
	enemy.position = boss_start.position
	
	enemy.dead = false
	enemy.set_physics_process(true)
	enemy.sprite.visible = true
	enemy.shadow.visible = true
	enemy.set_data()
	enemy.collider.set_deferred("disabled", false)
	enemy.hitbox_collisionshape.set_deferred("disabled", false)
	enemy.hurtbox_collisionshape.set_deferred("disabled", false)
	
	
#	enemy.connect("spawn_shop", spawn_shop)
#	enemy.connect("play_damage_sound", play_damage_sound)
#	enemy.connect("play_death_sound", play_death_sound)
	enemy.connect("spawn_damage_number", enemy_handler.spawn_damage_number)
	GameState.register_enemy.emit(enemy)
	
	for child in GameState.player.attack_handler.get_children():
		if child is Attack:
			# remove child from player except for first weapon later
			var new_attack = child.duplicate()
			enemy.attack_handler.add_child(new_attack)
	enemy.attack_handler.passive_all_attacks()
	enemy.attack_handler.aim_attacks_at_player()
	enemy.attack_handler.refresh_all_attacks()
	
	enemy.attack_handler.upgrade_all_attacks(boss_upgrade)
	
## NEED TO ADD THESE MODIFIERS TO ALL WEAPONS
## Make it an upgrade, call it Boss Upgrade and attach it directly
#	attack.bullet = GameState.player.all_bullets[i].duplicate(true)
#	attack.bullet.deactivation_range *= 5
#	attack.bullet.bullet_range *= 5
#	attack.bullet.shot_spread *= 8
#	attack.bullet.start_range *= 2
