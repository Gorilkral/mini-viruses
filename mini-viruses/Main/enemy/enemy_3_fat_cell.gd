# DÜŞMAN 3: Şişman Hücre (Tank Düşman)
# Görevi: Çok yavaş hareket eder ama yüksek canı ve hasarı vardır. Alanı daraltır.
# İstatistikleri: Çok yüksek can, çok yavaş hız, yüksek XP.

extends CharacterBody2D

@export var speed: float = 35.0
@export var max_health: float =  150.0
@export var min_xp_drop: int = 15
@export var max_xp_drop: int = 30
@export var attack_damage: float = 20.0 # Yavaş ama sağlam vurur

var current_health : float
var player: Node2D
var attack_cooldown: float = 0.0

func _ready():
	add_to_group("enemy")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		# Hasar Kontrolü
		if attack_cooldown > 0:
			attack_cooldown -= delta
			
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider != null and collider.is_in_group("player") and attack_cooldown <= 0:
				if collider.has_method("take_damage"):
					collider.take_damage(attack_damage)
					attack_cooldown = 1.5 # Tank olduğu için biraz daha yavaş vursun

func take_damage(damage_amount: float):
	current_health -= damage_amount
	if current_health <= 0:
		die()

func die():
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if player != null and player.has_method("add_xp"):
		player.add_xp(xp_drop)
		
	queue_free()
