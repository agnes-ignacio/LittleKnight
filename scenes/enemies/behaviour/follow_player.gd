extends Node2D

@export var speed = 1.0

var enemy: Enemy
var sprite: AnimatedSprite2D
var input_vector: Vector2

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	pass

func _physics_process(delta):
	if GameManager.is_game_over: return
	
	var player_position = GameManager.player_position
	
	var difference = player_position - enemy.position
	input_vector = difference.normalized()
	
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()
	flip_sprite()
	
	

func flip_sprite():
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
