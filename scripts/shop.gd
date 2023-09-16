extends Node2D

signal shop_entered

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
		print("exited inner radius")






