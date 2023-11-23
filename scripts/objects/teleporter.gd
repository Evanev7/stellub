extends Node2D

@export var destination: GameState.CURRENT_AREA

signal teleport_player

@onready var default_scale = scale
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	start()
	pass
	
	
func start():
	scale = default_scale
	$AnimatedSprite2D.animation = "xp_pickup"
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.self_modulate = Color(0.2, 0.2, 0.2)
	set_process(false)
	$teleporter/CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func enabled():
	$teleporter/CollisionShape2D.disabled = false
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)


func _on_teleporter_body_entered(body):
	if body == GameState.player:
		tween = create_tween()
		tween.tween_property(self, "global_scale", default_scale / 3, 3)
		# zoom camera in?
		await tween.finished
		#teleport_player.emit()
		GameState.load_area(destination)

func _on_teleporter_body_exited(body):
	if body == GameState.player:
		if tween.is_running():
			tween.stop()
		tween = create_tween()
		tween.tween_property(self, "global_scale", default_scale, 0.5)
