extends Node2D

signal shop_entered

@export var shop_limit: int = 5
@export var shop_resource_list: Array[ShopResource]

var shop_entries: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shop_entries = 0
	print(shop_limit)

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
		var stat_upgrades = []
		for i in 3:
			var rand_item = shop_resource_list[randi() % shop_resource_list.size()]
			stat_upgrades.append(rand_item)
		shop_entered.emit(stat_upgrades)


func disable():
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()




