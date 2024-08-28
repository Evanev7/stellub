extends Node

@onready var damage: float = GameState.player.hp_max * 0.3
@onready var hitbox: Area2D = $BossHeavenStatue/Hitbox
@onready var hurtbox: Area2D = $BossHeavenStatue/Hurtbox
@onready var boss_heaven_statue = $BossHeavenStatue
@onready var shadow = $Shadow

@onready var HP_MAX: float = damage
@onready var hp: float = HP_MAX


var following_player: bool = true
var height_above_player
var pos: Vector2
var _height
var falling: bool = false
var _drop_time

func _ready():
	hitbox.monitoring = false
	hurtbox.monitoring = false

func _physics_process(delta):
	if following_player:
		boss_heaven_statue.position = GameState.player.position + Vector2(0,-height_above_player)
		pos = GameState.player.position
	if falling:
		var dist = delta * height_above_player/_drop_time
		_height = max(_height - dist,0)
		boss_heaven_statue.position = pos - Vector2(0,_height)
	shadow.position = pos

	if _height < 10:
		hitbox.monitoring = true


func drop(height, drop_time = 0.6, shader_time = 0.6):
	_drop_time = drop_time
	height_above_player = height
	_height = height
	var tween: Tween = create_tween()
	$BossHeavenStatue/Sprite2D.material.set_shader_parameter("value", 0.)
	tween.tween_property($BossHeavenStatue/Sprite2D.material, "shader_parameter/value", 1., shader_time)
	tween.tween_interval(2)
	tween.tween_callback(func(): following_player = false)
	tween.tween_interval(0.4)
	tween.tween_callback(func(): falling = true)
	tween.tween_property(shadow, "offset", Vector2(0,0), drop_time)
	tween.parallel().tween_property(shadow.material, "shader_parameter/value", 1., drop_time)
	tween.chain().tween_callback(disable_damagebox)

func disable_damagebox():
	SoundManager.landing_sfx.play()
	hurtbox.monitoring = true

func _on_hitbox_area_entered(area):
	if area.owner == GameState.player:
		GameState.player.hurt(self)

func hurt(area):
	hp -= area.damage
	if hp <= 0:
		SoundManager.landing_sfx.play()
		print("drop an item")
		queue_free()
