extends Node2D

signal shop_entered(shop)
signal remove_target

@export var shop_resource_list: Array[ShopResource]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_particles: GPUParticles2D = $Fire
@onready var appear: AudioStreamPlayer2D = $appear

var chosen_upgrades
var is_weapon_present
var shop_opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	fire_particles.emitting = false
	appear.play()
	var tween: Tween = create_tween()
	tween.parallel().tween_property(sprite.material, "shader_parameter/value", 1.0, 2).from(0.0)


func _on_open_area_entered(body):
	if body == GameState.player:
		sprite.play("shop_open")
		fire_particles.emitting = true
			
		
func _on_open_area_exited(body):
	if body == GameState.player:
		sprite.play("shop_closed")
		fire_particles.emitting = false
		if shop_opened:
			ShopDraggable.shop_freed()
			remove()

func _on_interact_area_entered(body):
	if body == GameState.player:
		shop_entered.emit(self)
		shop_opened = true


func remove():
	$InteractArea/CollisionShape2D.disabled = true
	SoundManager.merchant_dialogue.play()
	var tween: Tween = create_tween()
	tween.tween_property(sprite.material, "shader_parameter/value", 0.0, 2).from(1.0)
	tween.tween_callback(queue_free)
