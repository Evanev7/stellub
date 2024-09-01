extends State

var ysort_node: Node2D
var object_locations: PathFollow2D
var origin: Vector2
@export var statue: PackedScene
@export var shadow_scene: PackedScene

var last_pos
@export var origin_approach_velocity: float = 600

var timer
var cur_to_drop
var dropped
@export var drop_height: float = 1000
@export var item_drop_gap: float = 5
@export var num_to_drop: int = 3
@export var num_variance: int = 1

func _ready():
	owner.give_me_data.emit(self)

func thanks_for_the_data(node: Node2D, path: PathFollow2D, centre: Marker2D):
	ysort_node = node
	object_locations = path
	origin = centre.position

func enter():
	timer = 0
	dropped = 0
	cur_to_drop = num_to_drop + randi_range(-num_variance, num_variance)

func physics_process(delta):
	var diff: Vector2 = owner.position - origin
	if diff.length_squared() > 600:
		owner.velocity = (origin-owner.position).normalized() * origin_approach_velocity
		last_pos = owner.position
	elif timer < 3.:
		owner.velocity = Vector2.ZERO
		timer += delta
		var percentage = clamp(1-(1-timer/3)**3,0,1)
		owner.position = last_pos * (1-percentage) + origin * percentage
	else:
		timer += delta
		owner.sprite.animation = "hold"
		owner.blocking = true

		if fmod(timer, item_drop_gap) > fmod(timer + delta, item_drop_gap) and dropped < num_to_drop:
			dropped += 1
			drop_a_brick_on_their_head()

func drop_a_brick_on_their_head():
	var object = statue.instantiate()
	ysort_node.add_child(object)
	object.drop(drop_height)

	if dropped >= num_to_drop:
		owner.sprite.animation = "boss"
		owner.blocking = false
		change_state.emit(self, "randomizer")
