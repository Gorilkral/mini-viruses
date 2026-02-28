# DÜŞMAN 6: Kamikaze (Patlayan Hücre)
# Görevi: Oyuncuya çok hızlı koşup dibine girince kendini patlatarak hasar vermek.

extends CharacterBody2D

@export var speed:float = 130.0
@export var max_health:float = 10.0
@export var explosion_damage:float = 25.0
@export var explosion_range:float = 35.0

var current_health
var player: Node2D

func _ready():
	current_health = max_health
	player = get_parent().get_node("Player")

func _physics_process(delta: float):
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		if distance <= explosion_range:
			explode()

func explode():
	if player.has_method("take_damage"):
		player.take_damage(explosion_damage)
		queue_free()

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()
