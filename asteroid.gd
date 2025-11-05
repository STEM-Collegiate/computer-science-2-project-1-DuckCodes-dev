extends Area2D

class_name Asteroid

signal on_asteroid_destroyed(size: AsteroidSize, position: Vector2)

var image_array = ["res://Assets/Sprites/Asteroid_01.png", "res://Assets/Sprites/Asteroid_02.png", "res://Assets/Sprites/Asteroid_03.png", "res://Assets/Sprites/Asteroid_04.png"]

const Utils = preload("res://Scenes/Utils/utils.gd")

@export var speed = 100
@export var speed_increment_factor = .3

var size = Utils.AsteroidSize.BIG
var direction: Vector2

@onready var sprite = $Sprite2D
@onready var explosion_particles = $ExplosionParticles

func _ready():
	var scaleValue = 1 / (size + 1.0)
	
	scale = Vector2(scaleValue, scaleValue)
	
	var random_index = randi() % image_array.size()
	var random_image = load(image_array[random_index])
	
	sprite.texture = random_image
	speed = speed + speed * size * speed_increment_factor
	
	var x = randf_range(-1, 1)
	var y = randf_range(-1, 1)
	direction = Vector2(x,y)

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body is Player && !(body as Player).is_invincible:
		body.die()
		on_destroy()

func emit_explosion():
	explosion_particles.emitting = true
	explosion_particles.reparent(get_tree().root)

func on_destroy():
	emit_explosion()
	queue_free()
	var new_asteroids_size = size + 1
	on_asteroid_destroyed.emit(new_asteroids_size, global_position)

func _on_area_entered(area):
	if area is Bullet || area is Ufo:
		area.queue_free()
		on_destroy()
