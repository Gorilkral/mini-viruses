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

var is_dead: bool = false

func _input(event):
	# Klavyede 'L' tuşuna basınca anında level atlatır
	if event is InputEventKey and event.pressed and event.keycode == KEY_O:
		die()

func _ready():
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
	is_dead = true # Ölüm süreci başladı
	
	# 1. Çarpışmaları kapatıyoruz (ölürken bize takılmasın)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. XP'yi oyuncuya gönderiyoruz (animasyon başlamadan önce)
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if is_instance_valid(player) and player.has_method("add_xp"):
		player.add_xp(xp_drop)
	
	# 3. KÜÇÜLEREK VE ŞEFFAFLAŞARAK SİLİNME ANİMASYONU (Tween)
	var tween = create_tween()
	
	# 0.3 saniye içinde boyutu (scale) 0'a getir (Kamikazenin tersi)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.3)
	# Aynı anda (parallel), 0.3 saniye içinde yavaşça görünmez yap (fade out)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Animasyon (0.3 saniye) bitene kadar fonksiyonu burada bekletiyoruz (await)
	await tween.finished
	
	# 4. Animasyon bitti, şimdi silinebiliriz
	queue_free()
