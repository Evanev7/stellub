extends AnimatableBody2D

var damage: float = 10
var following_player: bool = true
var height_above_player
var pos: Vector2
var _height
var falling: bool = false
var _drop_time

func _physics_process(delta):
	if following_player:
		$Shadow.offset = Vector2(0,height_above_player)
		position = GameState.player.position + Vector2(0,-height_above_player)
		pos = GameState.player.position
	if falling:
		var dist = delta * height_above_player/_drop_time
		
		_height = max(_height - dist,0)
		position = pos - Vector2(0,_height)

func drop(height, drop_time = 1, shader_time = 1):
	_drop_time = drop_time
	height_above_player = height
	_height = height
	var tween: Tween = create_tween()
	$Sprite2D.material.set_shader_parameter("value", 0.)
	tween.tween_property($Sprite2D.material, "shader_parameter/value", 1., shader_time)
	tween.tween_interval(2)
	tween.tween_callback(stop_following_player)
	tween.tween_interval(1)
	tween.tween_callback(fall)
	tween.tween_property($Shadow, "offset", Vector2(0,0), drop_time)
	tween.parallel().tween_property($Shadow.material, "shader_parameter/value", 1., drop_time)
	tween.chain().tween_callback(disable_damagebox)

func disable_damagebox():
	$Hitbox.process_mode = $Hitbox.PROCESS_MODE_DISABLED

func stop_following_player():
	following_player = false

func fall():
	falling = true
