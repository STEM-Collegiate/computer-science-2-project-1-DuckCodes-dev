extends Node

func _ready():
	$UI.restart_requested.connect(restart_game)
	$Player.reset()

func restart_game():
	for asteroid in $AsteroidsSpawner.get_children():
		asteroid.queue_free()
	
	$UI.set_points(0)
	$Player.reset()
	get_tree().reload_current_scene()
