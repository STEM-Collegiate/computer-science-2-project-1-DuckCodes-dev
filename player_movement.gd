extends CharacterBody2D

class_name Player

signal on_player_died

@export var max_speed = 10
@export var rotation_speed = 3.5
@export var velocity_damping_factor = .5
@export var linear_velocity = 200

@onready var invincibility_timer = $InvincibilityTimer
@onready var blinking_timer = $BlinkingTimer
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var engine_sprite = $EngineSprite
@onready var engine_audio_player = $EngineAudioPlayer

var is_invincible: bool = false
var input_vector: Vector2
var rotation_direction: int

func _ready():
	blinking_timer.timeout.connect(toggle_visibility)
	invincibility_timer.timeout.connect(stop_invincibility)

func _process(_delta):
	input_vector.x = Input.get_action_strength("rotate_left") - Input.get_action_strength("rotation_right")
	input_vector.y = Input.get_action_strength("thrust")
	
	if Input.is_action_pressed("rotate_left"):
		rotation_direction = -1
	elif Input.is_action_pressed("rotation_right"):
		rotation_direction = 1
	else:
		rotation_direction = 0
	
	if input_vector.y != 0:
		if !engine_audio_player.playing:
			engine_audio_player.play()
		
		animation_player.play("engine_animation")
	else:
		if engine_audio_player.playing:
			engine_audio_player.stop()
		
		animation_player.stop()
		engine_sprite.visible = false
	
	if Input.is_action_just_pressed("hyperspace"):
		activate_hyperspace()

func _physics_process(delta):
	rotation += rotation_direction * rotation_speed * delta
	
	if(input_vector.y > 0):
		accelerate_forward(delta)
	elif input_vector.y == 0 && velocity != Vector2.ZERO:
		slow_down_and_stop(delta)
	
	move_and_collide(velocity * delta)

func accelerate_forward(delta: float):
	velocity += (input_vector * linear_velocity * delta).rotated(rotation)
	velocity.limit_length(max_speed)

func slow_down_and_stop(delta: float):
	velocity = lerp(velocity, Vector2.ZERO, velocity_damping_factor * delta)
	
	if velocity.y >= -0.1 && velocity.y <= 0.1:
		velocity.y = 0

func die():
	set_process(false)
	set_physics_process(false)
	visible = false
	velocity = Vector2.ZERO
	on_player_died.emit()

func reset():
	global_position = Vector2(0, 0)  # Or use a passed-in position
	velocity = Vector2.ZERO
	input_vector = Vector2.ZERO
	rotation_direction = 0
	rotation = 0
	visible = true
	set_process(true)
	set_physics_process(true)
	start_invincibility()

func start_invincibility():
	is_invincible = true
	blinking_timer.start()
	invincibility_timer.start()

func toggle_visibility():
	if sprite.visible:
		sprite.visible = false
	else:
		sprite.visible = true

func stop_invincibility():
	is_invincible = false
	sprite.visible = true
	blinking_timer.stop()
	invincibility_timer.stop()

func activate_hyperspace():
	if randi_range(1, 6) == 1:
		die()
		return
	
	var viewport_rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_2d()
	var zoom = camera.zoom
	var camera_position = camera.position
	var size = viewport_rect.size / zoom
	
	var bounds = {
	"top": (camera_position.y - size.y) / 2,
	"bottom": (camera_position.y + size.y) / 2,
	"left": (camera_position.x - size.x) / 2,
	"right": (camera_position.x + size.x) / 2
	}
	
	var new_x = randi_range(bounds.left, bounds.right)
	var new_y = randi_range(bounds.top, bounds.bottom)
	
	global_position = Vector2(new_x, new_y)
	velocity = Vector2.ZERO
