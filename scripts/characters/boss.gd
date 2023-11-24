extends Node

func _ready():
	$Enemy/AttackHandler.passive_all_attacks()
	$Enemy/AttackHandler.aim_attacks_at_player()
	$Enemy/AttackHandler.refresh_all_attacks()
	add_to_group("boss")
	
## NEED TO ADD THESE MODIFIERS TO ALL WEAPONS
## Make it an upgrade, call it Boss Upgrade and attach it directly
#	attack.bullet = GameState.player.all_bullets[i].duplicate(true)
#	attack.bullet.deactivation_range *= 5
#	attack.bullet.bullet_range *= 5
#	attack.bullet.shot_spread *= 8
#	attack.bullet.start_range *= 2
