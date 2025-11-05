extends Node

class_name AsteroidsSpawner

signal points_updated(points: int)
signal high_score_updated(high_score: int)

@export var asteroid_scene: PackedScene
@export var count = 6
@export var base_asteroids_points = 50

@onready var explosion_audio_player = $"../ExplosionAudioPlayer"

const Utils = preload("res://Scenes/Utils/utils.gd")

var active_asteroids = 0
var wave_number: int = 0
var base_count = 6
var points = 0
var high_score = 0

func _ready():
	load_high_score()
	spawn_new_wave()

func get_random_position_from_screen_rect() -> Vector2:
	var rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_2d()
	var zoom = camera.zoom
	var camera_position = camera.position
	var size = rect.size / zoom
	var bounds = {}
	
	bounds.top = (camera_position.y - size.y) / 2
	bounds.bottom = (camera_position.y + size.y) / 2
	bounds.right = (camera_position.x + size.x) / 2
	bounds.left = (camera_position.x - size.x) / 2
	
	var x = randi_range(bounds.left, bounds.right)
	var y = randi_range(bounds.top, bounds.bottom)
	
	return Vector2(x, y)

func spawn_asteroid(size: Utils.AsteroidSize, position: Vector2):
	var asteroid = asteroid_scene.instantiate() as Asteroid
	add_child.call_deferred(asteroid)
	asteroid.global_position = position
	asteroid.size = size
	asteroid.on_asteroid_destroyed.connect(asteroid_destroyed)
	active_asteroids += 1

func asteroid_destroyed(size: int, position: Vector2):
	explosion_audio_player.play()
	
	active_asteroids -= 1
	
	points += base_asteroids_points * (size + 1)
	points_updated.emit(points)
	
	if points > high_score:
		high_score = points
		save_high_score()
		high_score_updated.emit(high_score)
	
	if (size <= 2):
		for i in range(2):
			spawn_asteroid(size, position)
	
	if active_asteroids == 0:
		spawn_new_wave()

func spawn_new_wave():
	wave_number += 1
	
	@warning_ignore("integer_division")
	var wave_count = base_count + int((wave_number - 1) / 5)
	
	wave_count = min(wave_count, 10)

	for i in range(wave_count):
		var random_spawn_position = get_random_position_from_screen_rect()
		
		spawn_asteroid(Utils.AsteroidSize.BIG, random_spawn_position)

func add_ufo_points():
	points += 200
	points_updated.emit(points)
	
	if points > high_score:
		high_score = points
		save_high_score()
		high_score_updated.emit(high_score)

func load_high_score():
	var save_path = "user://high_score.save"
	var file = FileAccess.open(save_path, FileAccess.READ)
	
	if file:
		high_score = int(file.get_line())
	else:
		high_score = 0
	
	high_score_updated.emit(high_score)

func save_high_score():
	var save_path = "user://high_score.save"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file:
		file.store_line(str(high_score))
