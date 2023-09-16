extends Node2D

signal shop_entered

@export var shop_limit: int = 1

var shop_entries: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start():
	shop_entries = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func move_shop():
	position = Vector2(position.x + randf_range(-2000, 2000), GameState.player.position.y + randf_range(-2000, -5000))


func _on_area_2d_body_entered(body):
	if body == GameState.player:
		$Shop_Closed.hide()
		$Shop_Open.show()
		
func _on_area_2d_body_exited(body):
	if body == GameState.player:
		$Shop_Open.hide()
		$Shop_Closed.show()

func _on_area_2d_2_body_entered(body):
	if body == GameState.player:
		shop_entered.emit()


func _on_area_2d_2_body_exited(body):
	if body == GameState.player:
		if shop_entries >= shop_limit:
			print("disable")
			call_deferred("disable")
		else:
			move_shop()

func disable():
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()




