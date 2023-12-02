extends HSlider

@export var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)

func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(new_value)
	)
	
	match bus_index:
		0:
			GameState.player_data.master_volume = new_value
		1:
			GameState.player_data.sfx_volume = new_value
		2:
			GameState.player_data.music_volume = new_value
	
