extends Node

@export var ufo_scene: PackedScene

@onready var timer = $Timer as UfoTimer
@onready var top_path = $PathTopLeftRight/PathToFollow
@onready var bottom_path = $PathBottomRightLeft/PathToFollow
@onready var ufo_hit_audio_player = $"../UfoHitAudioPlayer"

func _ready():
	timer.timeout.connect(spawn_ufo)

func spawn_ufo():
	var ufo = ufo_scene.instantiate() as Ufo
	ufo.ufo_destroyed.connect(on_ufo_destroyed)
	var path_to_follow = top_path if randf() > 0.5 else bottom_path as PathFollow2D
	
	for child in path_to_follow.get_children():
		child.queue_free()
	
	path_to_follow.progress = 0
	ufo.path = path_to_follow
	path_to_follow.add_child(ufo)
	timer.setup_timer()
	timer.start()

func on_ufo_destroyed():
	ufo_hit_audio_player.play()
	
	var asteroid_spawner = get_node("../AsteroidsSpawner") as AsteroidsSpawner
	asteroid_spawner.add_ufo_points()
