# DÜŞMAN 6: Kamikaze (Patlayan Hücre)
# Görevi: Oyuncuya çok hızlı koşup dibine girince kendini patlatarak hasar vermek.

extends CharacterBody2D

@export var speed:float = 130.0
@export var max_health:float = 10.0
@export var explosion_damage:float = 25.0
@export var explosion_range:float = 35.0
@export var min_xp_drop: int = 20
@export var max_xp_drop: int = 40

var current_health
var player: Node2D

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		if distance <= explosion_range:
			explode()

func explode():
	if player != null and player.has_method("take_damage"):
		player.take_damage(explosion_damage)
		queue_free() # Patlayıp yok olur

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if player != null and player.has_method("add_xp"):
		player.add_xp(xp_drop)
		
	queue_free()
