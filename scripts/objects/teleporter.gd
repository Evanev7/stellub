extends Node2D

@export var destination: GameState.CURRENT_AREA
@export var HUD: CanvasLayer

signal teleport_player

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	start()
	
	
func start():
	set_process(false)
	$teleporter/CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func enabled():
	$teleporter/CollisionShape2D.disabled = false
	$AnimatedSprite2D.play("active")


func _on_teleporter_body_entered(body):
	if body == GameState.player:
		tween = create_tween()
		tween.parallel().tween_property(HUD.vignette, "self_modulate:a", 3, 3)
		# zoom camera in?s
		await tween.finished
		#teleport_player.emit()
		GameState.load_area(destination)

func _on_teleporter_body_exited(body):
	if body == GameState.player:
		if tween.is_running():
			tween.stop()
		tween = create_tween()
		tween.parallel().tween_property(HUD.vignette, "self_modulate:a", 0.43, 1)
