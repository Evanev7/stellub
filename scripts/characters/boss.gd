extends CharacterBody2D


const SPEED = 300.0

const num_attacks = 4
var bullets = []

func _ready():
	$AttackHandler.passive_all_attacks()
#	attack.bullet = GameState.player.all_bullets[i].duplicate(true)
#	attack.bullet.deactivation_range *= 5
#	attack.bullet.bullet_range *= 5
#	attack.bullet.shot_spread *= 8
#	attack.bullet.start_range *= 2

func _physics_process(_delta):
	var player_direction: Vector2 = (GameState.player.position - position)
	velocity = player_direction.normalized() * 50
	move_and_slide()
