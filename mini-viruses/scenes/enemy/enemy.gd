extends CharacterBody2D

@export var speed : float = 100.0
@export var max_health : int = 10

var health : int

func _ready():
	health = max_health

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
