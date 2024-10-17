extends Resource
class_name PlayerData

@export var total_enemies_killed: int = 0
@export var total_souls_collected: float = 0
@export var total_pickups_collected: int = 0
@export var total_bullets_summoned: int = 0
@export var total_damage_dealt: float = 0
@export var total_circles_completed: int = 0
@export var total_deaths: int = 0
@export var unique_weapons_used: int:
	get:
		return len(unique_weapon_names.keys()) - 1
@export var unique_weapon_names: Dictionary
@export var total_upgrades_taken: int = 0
@export var total_weapons_taken: int = 0
@export var total_boss_kills: int = 0

@export var first_time: bool = true
@export var first_time_shop: bool = true
@export var first_time_heaven: bool = true
@export var first_time_boss: bool = true
@export var gamepad_enabled: bool = false
@export var damage_numbers_enabled: bool = true
@export var fps_enabled: bool = false

@export var master_volume: float = 0.7
@export var sfx_volume: float = 0.7
@export var music_volume: float = 0.7
