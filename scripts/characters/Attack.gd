extends Node
class_name Attack


@export var audio_player: AudioStreamPlayer

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
var hit: bool = false
var icon

var active_upgrades: Array[Upgrade]

func _ready():
	if not attack_direction:
		attack_direction = get_parent().attack_direction
	assert(attack_direction or aim_mode == AIM_MODE.TARGETED, "Fixed attack created without attack direction!")
	refresh_bullet_resource()
	if initial_bullet:
		icon = initial_bullet.icon
	_timer = 0.01
	attack_handler = get_parent()


func _physics_process(_delta):
	if not bullet:
		return
	
	if not bullet.fire_on_hit:
		if timer_active and _timer > 0:
			_timer -= 1
		elif _timer <= 0:
			if control_mode == CONTROL_MODE.PASSIVE:
				pre_fire()
		
		if control_mode != CONTROL_MODE.PASSIVE:
			if _timer <= 0 and Input.is_action_pressed(BIND[control_mode]):
				pre_fire()
	else:
		if timer_active and _timer > 0 and hit:
			_timer -= 1
		elif _timer <= 0:
			pre_fire()
			hit = false

func on_hit():
	hit = true
	if _timer <= 0:
		pre_fire()
	
func pre_fire():
	if aim_mode == AIM_MODE.TARGETED:
		attack_direction = attack_handler.get_attack_direction()
	
	for upgrade in get_children():
		if upgrade is Upgrade:
			upgrade.pre_fire()
	
	if attack_handler.owner == GameState.player or attack_direction.direction.length() < target_range:
		fire()
		_timer += bullet.fire_delay

func fire():
	audio_player.play()
	GameState.fire_bullet.emit(attack_handler.owner, bullet, attack_direction)

func reset():
	remove_upgrades()
	initial_bullet = null
	bullet = null

func refresh_bullet_resource():
	if not initial_bullet:
		return
	
	bullet = initial_bullet.duplicate()
	for upgrade in get_children():
		if upgrade is Upgrade:
			if bullet.spawned_bullet_resource:
				bullet.spawned_bullet_resource = upgrade.modify_bullet_resource(bullet.spawned_bullet_resource)
			bullet = upgrade.modify_bullet_resource(bullet)
		
	

func remove_upgrades():
	for child in get_children():
		if child is Upgrade:
			child.queue_free()








