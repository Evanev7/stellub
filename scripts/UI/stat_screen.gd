extends CanvasLayer

signal restart_game

@onready var levels_gained: Label = %Levels
@onready var enemies_killed: Label = %Enemies
@onready var souls_collected: Label = %Souls
@onready var bullets_summoned: Label = %Bullets
@onready var damage_dealt: Label = %Damage
@onready var circles_completed: Label = %Circles
@onready var deaths: Label = %Deaths
@onready var pickups_gathered: Label = %Pickups

@onready var restart_button = %RestartButton

var main = false
var restarting = false

func _ready():
	GameState.game_over.connect(game_over)
	GameState.stat_screen = self
	%DeathsLabel.hide()
	%PickupsLabel.hide()
	%UpgradesLabel.hide()
	%WeaponsLabel.hide()
	%BossLabel.hide()
	%LevelsLabel.show()
	levels_gained.show()
	deaths.hide()
	pickups_gathered.hide()
	%Upgrades.hide()
	%Weapons.hide()
	%Boss.hide()
	%Restart.text = "RESTART"

func game_over():
	GameState.player_data.total_upgrades_taken += GameState.upgrades_taken
	GameState.player_data.total_weapons_taken += max(GameState.weapons_taken.size() - 1, 0)
	GameState.save_game()
	show()
	var tween: Tween = create_tween()
	if GameState.player_data.first_time == true:
		$TextureRect.self_modulate = Color(1, 1, 1, 1)
		tween.tween_property($CenterContainer, "modulate:a", 1, 2)
	else:
		tween.tween_property($TextureRect, "self_modulate:a", 1, 0.5)
		tween.tween_property($CenterContainer, "modulate:a", 1, 0.5)
	levels_gained.text = str(GameState.player.current_level)
	enemies_killed.text = str(GameState.enemies_killed)
	souls_collected.text = str(int(GameState.souls_collected))
	bullets_summoned.text = str(GameState.bullets_summoned)
	damage_dealt.text = str(int(GameState.damage_dealt * 10))
	circles_completed.text = str(GameState.circles_completed - 1)


func _on_restart_button_pressed():
	if main == true:
		SoundManager.select.play()
		var tween: Tween = create_tween()
		var tween2: Tween = create_tween()
		tween.tween_property($CenterContainer, "modulate:a", 0, 1)
		tween2.tween_property($TextureRect, "self_modulate:a", 0, 1)
		tween.tween_callback(hide)
		tween2.tween_callback(func():
			get_parent().show()
			main = false
			)
	else:
		if GameState.player_data.first_time == true:
			var tween: Tween = create_tween()
			tween.tween_property($CenterContainer, "modulate:a", 0, 0.5)
			tween.tween_property($TextureRect/Label, "self_modulate:a", 1, 2)
			tween.tween_property($TextureRect/Label, "self_modulate:a", 0, 2)
			GameState.player_data.first_time = false
			tween.tween_callback(restart)
		else:
			restart()

func restart():
	if restarting == true:
		return
	else:
		restarting = true
	SoundManager.important_select.play()
	var tween: Tween = create_tween()
	var tween2: Tween = create_tween()
	tween.tween_property($CenterContainer, "modulate:a", 0, 1)
	tween2.tween_property($TextureRect, "self_modulate:a", 0, 1)
	tween2.tween_callback(func():
		hide()
		restarting = false)
	restart_game.emit()
	tween2.tween_callback(get_parent().start_message)

func opened_via_main():
	show()
	var tween: Tween = create_tween()
	tween.parallel().tween_property($TextureRect, "self_modulate:a", 1, 0.5)
	tween.parallel().tween_property($CenterContainer, "modulate:a", 1, 0.5)
	main = true
	%DeathsLabel.show()
	%PickupsLabel.show()
	%UpgradesLabel.show()
	%WeaponsLabel.show()
	if GameState.player_data.total_boss_kills:
		%BossLabel.show()
	%LevelsLabel.hide()
	levels_gained.hide()
	deaths.show()
	pickups_gathered.show()
	%Upgrades.show()
	%Weapons.show()
	if GameState.player_data.total_boss_kills:
		%Boss.show()
	%Restart.text = "BACK"

	enemies_killed.text = str(GameState.player_data.total_enemies_killed)
	souls_collected.text = str(int(GameState.player_data.total_souls_collected))
	bullets_summoned.text = str(GameState.player_data.total_bullets_summoned)
	damage_dealt.text = str(int(GameState.player_data.total_damage_dealt * 10))
	circles_completed.text = str(GameState.player_data.total_circles_completed)
	deaths.text = str(GameState.player_data.total_deaths)
	pickups_gathered.text = str(GameState.player_data.total_pickups_collected)
	%Upgrades.text = str(GameState.player_data.total_upgrades_taken)
	%Weapons.text = str(GameState.player_data.total_weapons_taken)
	if GameState.player_data.total_boss_kills:
		%Boss.text = str(GameState.player_data.total_boss_kills)



func _on_restart_button_mouse_entered():
	SoundManager.button_hover.play()
