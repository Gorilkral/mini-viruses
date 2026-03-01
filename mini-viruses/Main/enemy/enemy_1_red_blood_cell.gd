# DÜŞMAN 1: Temel Bakteri (Sürü Düşmanı)
# Görevi: Sahnede "player" etiketli karakteri bulup dümdüz üstüne yürümek.
# İstatistikleri: Düşük can, yavaş hız. XP kasmak için kesilen temel et yığını.

extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 20.0
@export var min_xp_drop: int = 1
@export var max_xp_drop: int = 5
@export var attack_damage: float = 10.0 # Düşmanın oyuncuya vuracağı hasar

var current_health: float
var player: Node2D
var attack_cooldown: float = 0.0 # Üst üste vurmayı engelleyecek sayaç

func _ready():
	add_to_group("enemy")
	current_health = max_health
	# Oyuncuyu grup ismiyle güvenli bir şekilde buluyoruz (Hata vermemesi için "player" küçük harf)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		# --- OYUNCUYA HASAR VERME (ÇARPIŞMA) KONTROLÜ ---
		# Sayacı her karede düşür
		if attack_cooldown > 0:
			attack_cooldown -= delta
			
		# Karakterin bir şeye çarpıp çarpmadığını kontrol et
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Çarptığımız şey "player" grubundaysa ve vurma süremiz (cooldown) dolduysa:
			if collider != null and collider.is_in_group("player") and attack_cooldown <= 0:
				if collider.has_method("take_damage"):
					collider.take_damage(attack_damage) # Oyuncunun canını azalt
					attack_cooldown = 1.0 # 1 saniye beklemeden tekrar hasar veremez

func take_damage(damage_amount: float):
	current_health -= damage_amount
	if current_health <= 0:
		die()

func die():
	# 1. min_xp_drop ve max_xp_drop arasında rastgele bir sayı seç (Örn: 1 ile 5 arası)
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	
	# 2. Oyuncu hayattaysa ve XP alma fonksiyonu varsa, puanı DİREKT hesabına yatır
	if player != null and player.has_method("add_xp"): # (Senin player.gd'de henüz gain_xp yoksa eklemeyi unutma!)
		player.add_xp(xp_drop)
	
	queue_free()
