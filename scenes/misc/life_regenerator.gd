extends Node2D

@export var healing_amount = 10

func _ready():
	$Area2D.body_entered.connect(on_body_entered)


func on_body_entered(body):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(healing_amount)
		player.meat_collected.emit(healing_amount)
		print("AQUI")
		queue_free()
