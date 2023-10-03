extends CharacterBody2D


const SPEED = 300.0

@onready var attack_1: EnemyAttack = $Attack_1
@onready var attack_2: EnemyAttack = $Attack_2
@onready var attack_3: EnemyAttack = $Attack_3
@onready var attack_4: EnemyAttack = $Attack_4

const num_attacks = 4
var bullets = []

func _ready():
	print("boss")
	print(GameState.player.all_bullets)
	for i in range(num_attacks):
		var attack = get_node("Attack_" + str(i + 1))
		if i < len(GameState.player.all_bullets):
			attack.bullet = GameState.player.all_bullets[i].duplicate(true)
			attack.bullet.deactivation_range *= 5
			attack.bullet.bullet_range *= 5
			attack.bullet.shot_spread *= 8
			attack.bullet.start_range *= 2
		else:
			attack.bullet = null
			

func _physics_process(_delta):
	var player_direction: Vector2 = (GameState.player.position - position)
	velocity = player_direction.normalized() * 50
	move_and_slide()

