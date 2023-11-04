extends Node
class_name Attack


enum CONTROL_MODE {PASSIVE, PRIMARY, SECONDARY, TERTIARY}
const BIND = ["","primary_fire", "secondary_fire", "tertiary_fire"]
@export var control_mode: CONTROL_MODE = CONTROL_MODE.PASSIVE

enum AIM_MODE {FIXED, TARGETED}
@export var aim_mode: AIM_MODE = AIM_MODE.TARGETED
var attack_direction: FireFrom
var target_range: float = 500

var attack_handler: AttackHandler
@export var initial_bullet: BulletResource
var bullet: BulletResource

var timer_active: bool = true
var _timer: float

var active_upgrades: Array[Upgrade]

func _ready():
	assert(attack_direction or aim_mode == AIM_MODE.TARGETED, "Fixed attack created without attack direction!")
	refresh_bullet_resource()
	_timer = bullet.fire_delay
	attack_handler = get_parent()


func _physics_process(_delta):
	if timer_active and _timer > 0:
		_timer -= 1
	elif _timer <= 0:
		if control_mode == CONTROL_MODE.PASSIVE:
			pre_fire()
	
	if control_mode != CONTROL_MODE.PASSIVE:
		if _timer <= 0 and Input.is_action_pressed(BIND[control_mode]):
			pre_fire()


func pre_fire():
	if aim_mode == AIM_MODE.TARGETED:
		attack_direction = attack_handler.get_attack_direction()
	
	
	for upgrade in get_children():
		upgrade.pre_fire()
	
	if owner == GameState.player or attack_direction.direction.length() < target_range:
		fire()
		_timer += bullet.fire_delay

func fire():
	GameState.fire_bullet.emit(attack_handler.owner, bullet, attack_direction)


func refresh_bullet_resource():
	bullet = initial_bullet.duplicate()
	for upgrade in get_children():
		bullet = upgrade.modify_bullet_resource(bullet)
		
	










