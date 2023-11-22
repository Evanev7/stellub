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
	enemies_killed.text = str(GameState.enemies_killed)
	souls_collected.text = str(int(GameState.souls_collected))
	bullets_summoned.text = str(GameState.bullets_summoned)
	damage_dealt.text = str(int(GameState.damage_dealt))


func _on_restart_button_pressed():
	restart_game.emit()
	hide()
