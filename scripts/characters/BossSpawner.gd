extends Node

@export var enemy_handler: EnemyHandler
@export var enemy_scene: PackedScene
@export var boss_resource: EnemyResource
@export var boss_start: Marker2D
@export var enemy_ysort: Node2D

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
	boss.boss_health_changed.connect(owner.HUD.show_boss_health)
	boss.attack_handler.stop()
	
	GameState.register_enemy.emit(boss)

