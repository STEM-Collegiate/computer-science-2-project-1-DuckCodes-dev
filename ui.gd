extends CanvasLayer

signal restart_requested

var life_texture = preload("res://Assets/Sprites/Lives.png")
var empty_life_texture = preload("res://Assets/Sprites/Player.png")

@onready var lifes_container: HBoxContainer = $MarginContainer/Control/LifesContainer
@onready var lifes_manager: LifesManager = $"../LifesManager"
@onready var asteroids_spawner: AsteroidsSpawner = $"../AsteroidsSpawner"
@onready var game_over_label: Label = $"%GameOverLabel"
@onready var points_label: Label = $"%PointsLabel"
@onready var restart_prompt_label: Label = $"%RestartPromptLabel"
@onready var restart_timer: Timer = $RestartTimer
@onready var high_score_label: Label = $MarginContainer/Control/HBoxContainer/HighScoreLabel

var waiting_for_restart = false
var restart_ready = false
var high_score = 0

func _ready():
	var lifes = lifes_manager.lifes
	set_process_unhandled_input(true)
	
	var config = ConfigFile.new()
	var err = config.load("user://save.cfg")

	if err == OK:
		high_score = config.get_value("scores", "high_score", 0)
		high_score_label.text = "High Score: %d" % high_score

	for i in range(lifes):
		var life_text_rect = TextureRect.new()
		life_text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		life_text_rect.stretch_mode = TextureRect.STRETCH_SCALE
		life_text_rect.texture = life_texture
		life_text_rect.custom_minimum_size = Vector2(32, 32)
		lifes_container.add_child(life_text_rect)
	
	lifes_manager.player_life_lost.connect(life_lost)
	asteroids_spawner.points_updated.connect(set_points)

func life_lost(lifes_left):
	if lifes_left >= 0 and lifes_left < lifes_container.get_child_count():
		var life_texture_rect: TextureRect = lifes_container.get_child(lifes_left)
		life_texture_rect.texture = empty_life_texture
	
	if lifes_left == 0:
		game_over_label.visible = true
		restart_prompt_label.visible = true
		waiting_for_restart = true
		restart_timer.start()

func set_points(points: int):
	points_label.text = "%d" % points
	
	if points > high_score:
		high_score = points
		update_high_score_display()

func update_high_score_display():
	high_score_label.text = "High Score: %d" % high_score
	
	var config = ConfigFile.new()
	
	config.set_value("scores", "high_score", high_score)
	config.save("user://save.cfg")

func _unhandled_input(event):
	if waiting_for_restart and restart_ready and event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ENTER:
			waiting_for_restart = false
			restart_ready = false
			restart_prompt_label.visible = false
			game_over_label.visible = false
			restart_requested.emit()
		elif event.keycode == KEY_BACKSPACE:
			get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")

func _on_restart_timer_timeout():
	restart_ready = true
