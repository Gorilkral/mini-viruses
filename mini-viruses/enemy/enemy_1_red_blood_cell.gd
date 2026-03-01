# DÜŞMAN 1: Temel Bakteri (Sürü Düşmanı)
# Görevi: Sahnede "Player" etiketli karakteri bulup dümdüz üstüne yürümek.
# İstatistikleri: Düşük can, yavaş hız. XP kasmak için kesilen temel et yığını.

extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 20.0
@export var min_xp_drop: int = 1
@export var max_xp_drop: int = 5


var current_health: float
var player: Node2D

func _ready():
	current_health=max_health
	player = get_parent().get_node("Player")

func _physics_process(delta: float):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()

func take_damage(damage_amount: float):
	current_health -= damage_amount
	if current_health <= 0:
		die()

func die():
	# 1. min_xp_drop ve max_xp_drop arasında rastgele bir sayı seç (Örn: 1 ile 5 arası)
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	
	# 2. Oyuncu hayattaysa ve XP alma fonksiyonu varsa, puanı DİREKT hesabına yatır
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(xp_drop)
	
	queue_free()
