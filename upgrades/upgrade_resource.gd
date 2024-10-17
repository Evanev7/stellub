extends Resource

class_name UpgradeResource

@export var upgrade_name: String
@export var upgrade_script: Script

@export var rarity: int = 1
@export var quantity: int = 10
@export var appears_in_shop: bool = true
@export var appears_in_inventory: bool = true
@export var icon: CompressedTexture2D
@export_multiline var description: String = "Default Upgrade Description"

@export var script_data: Dictionary
