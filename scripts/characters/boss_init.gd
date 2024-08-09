extends State

@export_range(0,10) var duration: float = 2.5
@export_range(1,5) var exponent: float = 2

var pathfollow: PathFollow2D
var timer: float = 0

func _ready():
	owner.give_me_data.emit(self)

func thanks_for_the_data(path):
	pathfollow = path

func physics_process(delta):
	if pathfollow:
		timer += delta
		if timer >= duration:
			SoundManager.boss_song_play()
			owner.attack_handler.start()
			owner.flap.volume_db = -6
			owner.boss_health_changed.emit(owner.health, owner.resource.MAX_HP*owner.overall_multiplier*owner.unique_multiplier)
			change_state.emit(self, "circleplayer")
			return
		pathfollow.progress_ratio = (timer/duration)**exponent
		owner.position = pathfollow.position

func enter():
	timer = 0
