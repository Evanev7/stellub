extends Node2D

signal shop_entered
signal remove_target

@export var shop_resource_list: Array[ShopResource]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_open_area_entered(body):
	if body == GameState.player:
		sprite.play("shop_open")
			
		
func _on_open_area_exited(body):
	if body == GameState.player:
		sprite.play("shop_closed")

func _on_interact_area_entered(body):
	if body == GameState.player:
		shop_entered.emit()


func disable():
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()


func _on_upgrade_hud_leave():
	get_tree().paused = false
	GameState.player.evolve()
	queue_free()
