class_name Player

extends CharacterBody2D

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sword_area = $Area2D
@onready var hit_area = $ReceiveDamageArea
@onready var health_bar = $HealthBar

@export_category("movement")
@export var speed = 3

@export_category("damage")
@export var sword_damage = 2

@export_category("health")
@export var health = 100
@export var max_health = 100
@export var death_prefab: PackedScene

@export_category("ritual")
@export var ritual_damage = 1
@export var ritual_interval = 30.0
@export var ritual_scene: PackedScene


var input_vector = Vector2(0,0)
var is_running = false
var was_running = false
var is_attacking = false
var attack_cooldown = 0.0
var hit_area_cooldown = 0.0
var ritual_cooldown = 0.0

signal meat_collected(value)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value): GameManager.meat_counter += 1)

func _process(delta):
	GameManager.player_position = position
	
	read_input()
	
	apply_attack_cooldown(delta)
	
	update_movement_animation()
	
	if not is_attacking:
		flip_sprite()
	
	update_hitarea_detection(delta)

	update_ritual(delta)
	
	health_bar.max_value = max_health
	health_bar.value = health
	
func _physics_process(delta):
	var target_velocity = input_vector * speed * 100.0
	
	if is_attacking:
		target_velocity *= 0.25
		
	velocity = lerp(velocity, target_velocity, 0.5)
	move_and_slide()

func apply_attack_cooldown(delta):
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animationPlayer.play("idle")

func update_movement_animation():
		if not is_attacking:
			if was_running != is_running:
				if is_running:
					animationPlayer.play("run")
				else:
					animationPlayer.play("idle")

func flip_sprite():
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func read_input():
	input_vector = Input.get_vector("move_left","move_right", "move_up", "move_down", 0.15)
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
	var was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
func attack():
	if is_attacking:
		return
	
	animationPlayer.play("attack_side_1")
	attack_cooldown = 0.6
	
	is_attacking = true
	
func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
				
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.4 :
				enemy.damage(sword_damage)

func update_hitarea_detection(delta):
	hit_area_cooldown -= delta
	if hit_area_cooldown > 0: return
	
	hit_area_cooldown = 0.5
	
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
			
			
	 

func damage(amount):
	if health <= 0: return
	
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	health -= amount
	
	if health <= 0:
		die()
	
func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()

func heal(healing_amount):
	health += healing_amount
	if health > max_health:
		health = max_health
	return health

func update_ritual(delta):
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	ritual_cooldown = ritual_interval
	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
