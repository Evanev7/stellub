extends Resource
class_name SaveGame

const save_path := "res://save"

@export var version := 0.1

@export var player_data: Resource = PlayerData.new()


func write_savegame() -> void:
	ResourceSaver.save(self, SaveGame.get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())

static func load_savegame() -> Resource:
	var SAVE_GAME_PATH := get_save_path()
	if not ResourceLoader.has_cached(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	return null

static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return save_path + extension
