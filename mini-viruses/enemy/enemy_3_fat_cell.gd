extends CharacterBody2D

@export var speed: float = 35
@export var max_health: float =  150

var current_health : float
var player: Node2D

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float):
		if  player != null:
			var direction = global_position.direction_to(player.global_position)
			velocity= direction*speed
			move_and_slide()

func take_damage(damage_amount: float):
	current_health -= damage_amount
	if current_health <= 0:
		die()

func die():
	queue_free() 

	move_and_slide()
