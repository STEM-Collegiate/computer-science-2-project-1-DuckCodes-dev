extends Area2D

class_name Bullet

signal ufo_hit

var direction: Vector2
var owner_type: String = ""

@export var bullet_speed = 700

@onready var explosion_particles = $ExplosionParticles

func _process(delta):
	position += direction * bullet_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if owner_type == "enemy" and body is Player && !(body as Player).is_invincible:
		body.die()
		queue_free()

func _on_area_entered(area):
	if owner_type == "player" and area is Ufo:
		ufo_hit.emit()
		queue_free()
		area.queue_free()
		explosion_particles.emitting = true
		explosion_particles.reparent(get_tree().root)
