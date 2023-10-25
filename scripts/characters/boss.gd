extends Node

var bullets = []
var damage_scene_pool: Array[DamageNumber] = []

func _ready():
	$Enemy/AttackHandler.passive_all_attacks()
	add_to_group("boss")
	
## NEED TO ADD THESE MODIFIERS TO ALL WEAPONS
#	attack.bullet = GameState.player.all_bullets[i].duplicate(true)
#	attack.bullet.deactivation_range *= 5
#	attack.bullet.bullet_range *= 5
#	attack.bullet.shot_spread *= 8
#	attack.bullet.start_range *= 2

#func _physics_process(_delta):
#	var player_direction: Vector2 = (GameState.player.position - position)
#	velocity = player_direction.normalized() * 50
#	move_and_slide()

#func hurt(area):
#	health -= area.damage
#	scale = default_scale * 0.65 
#	var tween2 := create_tween()
#	tween2.tween_property(self, "global_scale", default_scale, 0.1)
#	spawn_damage_number(area.damage)
	
#func spawn_damage_number(damage_value: float):
#	var damage_number = get_damage_number()
#	var val = damage_value
#	var pos = $DamageNumber.position
#	$DamageNumbers.add_child(damage_number, true)
#	damage_number.set_values_and_animate(val, pos, $DamageNumbers.get_child_count() * 5, 100 + 5 * $DamageNumbers.get_child_count())
#
#func get_damage_number() -> DamageNumber:
#	if damage_scene_pool.size() > 0:
#		return damage_scene_pool.pop_front()
#
#	else:
#		var new_damage_number = damage_scene.instantiate()
#		new_damage_number.tree_exiting.connect(
#			func():
#				damage_scene_pool.append(new_damage_number))
#		return new_damage_number
