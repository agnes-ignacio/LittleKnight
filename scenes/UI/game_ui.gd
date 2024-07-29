extends CanvasLayer

@onready var timer_label = %Timer
@onready var meat_label = %MeatLabel

func _process(delta):
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
