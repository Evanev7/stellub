extends Node2D

signal enemy_killed(enemy)
signal spawn_shop(pos)
signal play_damage_sound(pos)
signal play_death_sound(pos)

var enemy_limit = 125
var enemies: Array = []


enum ENEMY {CRU, WAR, WOR, DOG, LOR, SKE, SKU}


class EnemyData:
	static var resources = {
		ENEMY.CRU: preload("res://resources/enemy/angel_crusader.tres"),
		ENEMY.WAR: preload("res://resources/enemy/angel_warrior.tres"),
		ENEMY.WOR: preload("res://resources/enemy/angel_worshipper.tres"),
		ENEMY.DOG: preload("res://resources/enemy/demon_dog.tres"),
		ENEMY.LOR: preload("res://resources/enemy/demon_lord.tres"),
		ENEMY.SKE: preload("res://resources/enemy/demon_skeleton.tres"),
		ENEMY.SKU: preload("res://resources/enemy/demon_skull.tres")
	}
	
	var type
	var resource: EnemyResource
	var collider
	
	func _init(init_type):
		type = init_type
		resource = resources[init_type]

static var enemy_types: Array[EnemyData] 

class ServerEnemy:
	var pos = Vector2()
	var body = RID()
	
	var resource: EnemyResource
	var data: EnemyData
	var texture: ImageTexture
	
	var unique_multiplier: float
	var overall_multiplier: float
	var health: float
	var damage: float
	var value: float
	var strength: float
	var speed: float
	var flipped: bool
	var floating: bool
	var default_angle: float
	var default_scale: Vector2
	var variance = 1/default_scale.length()
	var dead: bool = false
	
	var fire_on_hit: bool = false
	
	static var damage_scene_pool: Array[DamageNumber] = []
	var movement_enabled: bool = true
	
	var velocity: Vector2
	
	func _init(init_data: EnemyData):
		GameState.num_enemies += 1
		data = init_data
		resource = data.resource
		load_resource(resource)
		texture = get_enemy_texture()
		
	func get_enemy_texture():
		var frames := resource.ANIMATION
		var image := frames.get_frame_texture(frames.get_animation_names()[0],0).get_image()
		image.resize(floor(image.get_height()*default_scale.x), floor(image.get_width()*default_scale.y))
		var texture = ImageTexture.create_from_image(image)
		return texture

	func load_resource(resource_to_load: EnemyResource):
		unique_multiplier = resource_to_load.UNIQUE_MULTIPLIER
		overall_multiplier = resource_to_load.OVERALL_MULTIPLIER


		health = resource_to_load.MAX_HP * unique_multiplier * overall_multiplier
		damage = resource_to_load.DAMAGE * unique_multiplier * overall_multiplier
		value = resource_to_load.VALUE * unique_multiplier * overall_multiplier
		strength = resource_to_load.STRENGTH * (0.5 + ((unique_multiplier  * overall_multiplier) / 2))
		speed = resource_to_load.SPEED / (0.9 + (unique_multiplier / 10))
		flipped = resource_to_load.FLIP_H
		floating = resource_to_load.FLOATING
		default_scale = resource_to_load.SCALE * (0.75 + (unique_multiplier / 4))
		variance = 1/default_scale.length()

func _ready():
	for type in range(7):
		var data = EnemyData.new(type)
		data.collider = PhysicsServer2D.capsule_shape_create()
		PhysicsServer2D.shape_set_data(data.collider, Vector2(data.resource.COLLIDER.height, data.resource.COLLIDER.radius))
		enemy_types.append(data)
		
		create_enemy(data, Vector2(960,540))
		

func create_enemy(data: EnemyData, placement: Vector2):
	var enemy = ServerEnemy.new(data)
	enemy.body = PhysicsServer2D.body_create()
	PhysicsServer2D.body_set_space(enemy.body, get_world_2d().get_space())
	PhysicsServer2D.body_add_shape(enemy.body, enemy.data.collider)
	enemy.pos = placement
	var transform2d = Transform2D()
	transform2d.origin = enemy.pos
	PhysicsServer2D.body_set_state(enemy.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)
	enemies.push_back(enemy)


func _physics_process(_delta):
	for enemy in enemies:
		var player_direction = (GameState.player.position - position)
		enemy.velocity = player_direction.normalized() * enemy.speed
		PhysicsServer2D.body_set_state(enemy.body, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, enemy.velocity)


func _process(_delta):
	queue_redraw()

func _draw():
	for enemy in enemies:
		draw_texture(enemy.texture, enemy.pos)

	

func _exit_tree():
	for enemy in enemies:
		PhysicsServer2D.free_rid(enemy.body)
	for enemy_type in enemy_types:
		PhysicsServer2D.free_rid(enemy_type.collider)
	enemies.clear()
