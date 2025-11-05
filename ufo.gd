extends Area2D

class_name Ufo

signal ufo_destroyed

@onready var explosion_particles = $ExplosionParticles
@onready var shooting_timer = $ShootingTimer
@onready var ufo_shot_audio_player = $UfoShotAudioPlayer

@export var bullet_scene: PackedScene
@export var path: PathFollow2D

var speed = 300
var current_point_on_path = 0

func _ready():
	shooting_timer.timeout.connect(shoot)

func _process(delta):
	if path == null:
		return
	
	var progress = delta * speed;
	path.progress += progress

func shoot():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.owner_type = "enemy"
	bullet.set_collision_layer_value(2, 0)
	bullet.set_collision_layer_value(5, 1)

	get_tree().root.add_child(bullet)
	bullet.position = global_position
	bullet.direction = get_random_shot_direction()
	ufo_shot_audio_player.play()

func get_random_shot_direction():
	var node_y = get_global_transform().origin.y
	var screen_height = get_viewport().get_visible_rect().size.y
	
	var should_shot_down = node_y <= screen_height / 2
	
	if should_shot_down:
		var angle = deg_to_rad(randf_range(45, 135))
		return Vector2(cos(angle), sin(angle))
	else:
		var angle = deg_to_rad(randf_range(225, 315))
		return Vector2(cos(angle), sin(angle))

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area is Bullet and area.owner_type == "player":
		ufo_destroyed.emit()
		call_deferred("queue_free")
		area.queue_free()
		explosion_particles.emitting = true
		explosion_particles.reparent(get_tree().root)
	elif area is Asteroid:
		ufo_destroyed.emit()
		queue_free()
		area.queue_free()
		explosion_particles.emitting = true
		explosion_particles.reparent(get_tree().root)
