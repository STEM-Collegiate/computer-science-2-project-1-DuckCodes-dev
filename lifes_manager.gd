extends Node

class_name LifesManager

signal player_life_lost(lifes_left: int)

const player_start_position = Vector2(0, 0)

@export var lifes = 3

var player_scene = preload("res://Scenes/player.tscn")

@onready var player = $"../Player" as Player

func _ready():
	player.on_player_died.connect(decrease_lifes)

func decrease_lifes():
	lifes -= 1
	player_life_lost.emit(lifes)

	if lifes > 0:
		player.reset()
		player.global_position = player_start_position
		player.start_invincibility()
	else:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
