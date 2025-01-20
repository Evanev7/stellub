extends CanvasLayer

enum {SAVE, LOAD}

@onready var dialogue_container: TextureRect = $Dialogue
@onready var dialogue_text: Label = $Dialogue/DialogueBox

@export var num_shop_nodes = 8

var attached_shop

func _ready():
	GameState.shop_HUD = self


func first_time_dialogue():
	dialogue_container.show()
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_container, "modulate:a", 1, 2)
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(2.0).timeout
	continue_dialogue()


func continue_dialogue():
	await get_tree().create_timer(3.0).timeout
	dialogue_text.text = "You may take one Rune every time we meet."
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(5.0).timeout
	dialogue_text.text = "It will do you more good than I."
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(4.0).timeout
	dialogue_text.text = "They may be rearranged once taken."
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(4.0).timeout
	dialogue_text.text = "You must activate at least 6 of these sites to escape."
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(4.0).timeout
	dialogue_text.text = "Good luck."
	SoundManager.merchant_dialogue.play()
	await get_tree().create_timer(3.0).timeout
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_container, "modulate:a", 0, 2)
	tween.tween_callback(dialogue_container.hide)


func populate_shop(shop_items):
	for index in range(num_shop_nodes):
		var shop_node = get_node("%Shop" + str(index+1))
		if index < shop_items.size():
			shop_node.referenced_node = shop_items[index]
		else:
			shop_node.referenced_node = null
		shop_node.refresh()


func clear_shop():
	attached_shop.chosen_upgrades = []
	for index in range(1,num_shop_nodes+1):
		var shop_node = get_node("%Shop" + str(index))
		if shop_node.referenced_node:
			attached_shop.chosen_upgrades.append(shop_node.referenced_node)


func open_shop(shop):
	attached_shop = shop
	populate_shop(attached_shop.chosen_upgrades)


func _on_shop_exit_pressed():
	SoundManager.select.play()
	GameState.player_data.first_time_shop = false
	close_shop()


func close_shop():
	GameState.unpause_game()
	set_visible(false)
	clear_shop()


func _on_shop_item_taken():
	for i in range(num_shop_nodes):
		get_node("%Shop"+str(i+1)).disabled = true


func _gray_out_shop():
	for index in range(num_shop_nodes):
		get_node("%Shop"+str(index+1)).refresh()
