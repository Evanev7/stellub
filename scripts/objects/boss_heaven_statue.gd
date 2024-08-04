extends Node

@onready var landing_sfx = $LandingSFX

@onready var damage: float = GameState.player.hp_max * 0.3
var following_player: bool = true
var height_above_player
var pos: Vector2
var _height
var falling: bool = false
var _drop_time

func _ready():
	$BossHeavenStatue/Hitbox.set_deferred("disabled", false)

func _physics_process(delta):
	if following_player:
		$BossHeavenStatue.position = GameState.player.position + Vector2(0,-height_above_player)
		pos = GameState.player.position
	if falling:
		var dist = delta * height_above_player/_drop_time
		_height = max(_height - dist,0)
		$BossHeavenStatue.position = pos - Vector2(0,_height)
	$Shadow.position = pos
	
	if _height < 100:
		$BossHeavenStatue.collision_mask = 1
		$BossHeavenStatue.collision_layer = 1
	

func drop(height, drop_time = 0.6, shader_time = 0.6):
	_drop_time = drop_time
	height_above_player = height
	_height = height
	var tween: Tween = create_tween()
	$BossHeavenStatue/Sprite2D.material.set_shader_parameter("value", 0.)
	tween.tween_property($BossHeavenStatue/Sprite2D.material, "shader_parameter/value", 1., shader_time)
	tween.tween_interval(2)
	tween.tween_callback(func(): following_player = false)
	tween.tween_interval(1)
	tween.tween_callback(func(): falling = true)
	tween.tween_property($Shadow, "offset", Vector2(0,0), drop_time)
	tween.parallel().tween_property($Shadow.material, "shader_parameter/value", 1., drop_time)
	tween.chain().tween_callback(disable_damagebox)

func disable_damagebox():
	$BossHeavenStatue/Hitbox.set_deferred("disabled", true)
	landing_sfx.play()

func _on_hitbox_area_entered(area):
	if area.owner == GameState.player:
		GameState.player.hurt(self)
