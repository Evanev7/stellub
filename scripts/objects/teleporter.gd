extends Node2D

@export var destination: GameState.CURRENT_AREA
@export var HUD: CanvasLayer
@onready var teleport_sound: AudioStreamPlayer2D = $teleport_sound
@onready var arrive_sound: AudioStreamPlayer = $arrive_sound

signal teleport_player
signal add_objective_marker(teleporter)

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	start()
	
	
func start():
	set_process(false)
	$teleporter/CollisionShape2D.disabled = true
	$Active.visible = false
	
	if GameState.current_area == GameState.CURRENT_AREA.HELL:
		$Bones.visible = true
		$Tree.visible = false
		$BonesCollision1.disabled = false
		$BonesCollision2.disabled = false
		$TreeCollision1.disabled = true
		$TreeCollision2.disabled = true
		$TreeCollision3.disabled = true
		
	elif GameState.current_area == GameState.CURRENT_AREA.HEAVEN:
		$Bones.visible = false
		$Tree.visible = true
		$BonesCollision1.disabled = true
		$BonesCollision2.disabled = true
		$TreeCollision1.disabled = false
		$TreeCollision2.disabled = false
		$TreeCollision3.disabled = false

func enabled():
	$teleporter/CollisionShape2D.disabled = false
	$Active.visible = true
	add_objective_marker.emit(self)


func _on_teleporter_body_entered(body):
	if body == GameState.player:
		tween = create_tween()
		tween.parallel().tween_property(HUD.vignette, "self_modulate:a", 3, 3)
		# zoom camera in?s
		await tween.finished
		if SoundManager.currently_playing_music:
			SoundManager.fade_out(SoundManager.currently_playing_music)
		get_tree().call_group("enemy", "remove")
		var camera = GameState.player.camera_2d
		GameState.player.attack_handler.stop()
		GameState.player.hide()
		GameState.player.get_node("CollisionShape2D").disabled = true
		GameState.player.get_node("Hurtbox/CollisionShape2D").disabled = true
		GameState.player.set_physics_process(false)
		teleport_sound.play()
		var tween2: Tween = create_tween()
		tween2.parallel().tween_property(HUD.get_node("VignetteTop"), "self_modulate", Color(100, 100, 100, 1), 2)
		tween2.parallel().tween_property(camera, "zoom", Vector2(0.9, 0.9), 2).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween2.finished
		GameState.load_area(destination)
		arrive_sound.play()

func _on_teleporter_body_exited(body):
	if body == GameState.player:
		if tween.is_running():
			tween.stop()
		tween = create_tween()
		tween.parallel().tween_property(HUD.vignette, "self_modulate:a", 0.43, 1)
