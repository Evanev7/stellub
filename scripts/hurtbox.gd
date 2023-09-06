class_name Hurtbox
extends Area2D

func _init():
	collision_layer = 0
	collision_mask = 2

func _ready():
	connect("area_entered",Callable(self,"_on_area_entered"))
	
func _on_area_entered(hitbox: Hitbox):
	if hitbox == null:
		return
	if owner.has_method("hurt"):
		owner.hurt(hitbox)
