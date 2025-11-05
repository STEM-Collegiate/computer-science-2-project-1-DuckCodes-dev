extends Timer

class_name UfoTimer

@export var min_time = 5
@export var max_time = 15

func _ready():
	setup_timer()

func setup_timer():
	self.stop()
	var timeout_value = randi_range(min_time, max_time)
	self.wait_time = timeout_value
	self.start()
