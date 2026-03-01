# DÜŞMAN 2: Kamçılı Hücre (Hızlı Düşman)
# Görevi: Sürünün arkasından fırlayıp oyuncuyu darlamak ve sürekli kaçmaya zorlamak.
# İstatistikleri: Çok düşük can, yüksek hız.

extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: float =  5.0
@export var min_xp_drop: int = 3
@export var max_xp_drop: int = 7

var current_health : float
var player: Node2D

func _ready():
	current_health=max_health
	player = get_parent().get_node("Player")

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
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(xp_drop)
		
	queue_free() 
