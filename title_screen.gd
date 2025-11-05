extends Node

@onready var high_score_label: Label = $MarginContainer/Control/HBoxContainer/HighScoreLabel

var input_ready = false

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://save.cfg")
	
	if not $InputDelayTimer.is_connected("timeout", Callable(self, "_on_input_delay_timer_timeout")):
		$InputDelayTimer.timeout.connect(_on_input_delay_timer_timeout)
	
	if err == OK:
		var high_score = config.get_value("scores", "high_score", 0)
		high_score_label.text = "High Score: %d" % high_score

func _unhandled_input(event):
	if input_ready and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_input_delay_timer_timeout():
	input_ready = true
