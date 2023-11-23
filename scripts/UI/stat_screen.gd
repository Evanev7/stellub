extends CanvasLayer

signal restart_game()

@onready var enemies_killed: Label = %Enemies
@onready var souls_collected: Label = %Souls
@onready var bullets_summoned: Label = %Bullets
@onready var damage_dealt: Label = %Damage
@onready var restart_button = %RestartButton

func _ready():
	GameState.game_over.connect(game_over)

func game_over():
	show()
	var tween: Tween = create_tween()
	if GameState.first_time == true:
		$TextureRect.self_modulate = Color(1, 1, 1, 1)
		tween.tween_property($CenterContainer, "modulate:a", 1, 2)
	else:
		tween.tween_property($TextureRect, "self_modulate:a", 1, 0.5)
		tween.tween_property($CenterContainer, "modulate:a", 1, 0.5)
	enemies_killed.text = str(GameState.enemies_killed)
	souls_collected.text = str(int(GameState.souls_collected))
	bullets_summoned.text = str(GameState.bullets_summoned)
	damage_dealt.text = str(int(GameState.damage_dealt))


func _on_restart_button_pressed():
	if GameState.first_time == true:
		var tween: Tween = create_tween()
		tween.tween_property($CenterContainer, "modulate:a", 0, 0.5)
		tween.tween_property($TextureRect/Label, "self_modulate:a", 1, 2)
		tween.tween_property($TextureRect/Label, "self_modulate:a", 0, 2)
		GameState.first_time = false
		tween.tween_callback(restart)
	else:
		restart()
		
func restart():
	var tween: Tween = create_tween()
	var tween2: Tween = create_tween()
	tween.tween_property($CenterContainer, "modulate:a", 0, 1)
	tween2.tween_property($TextureRect, "self_modulate:a", 0, 1)
	tween2.tween_callback(hide)
	restart_game.emit()
	tween2.tween_callback(get_parent().start_message)
	
