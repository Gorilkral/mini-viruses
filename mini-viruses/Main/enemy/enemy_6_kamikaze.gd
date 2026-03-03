# DÜŞMAN 6: Kamikaze (Patlayan Hücre)
extends CharacterBody2D

@export var speed:float = 300.0
@export var max_health:float = 10.0
@export var explosion_damage:float = 25.0
@export var explosion_range:float = 200.0 # BÜYÜTÜLDÜ! (Çarpışma mesafesinden büyük olmalı ki hasar versin)
@export var min_xp_drop: int = 6
@export var max_xp_drop: int = 13

var current_health: float
var player: Node2D
var is_exploding: bool = false # Patlama sürecinde mi?

var is_dead: bool = false

func _ready():
	add_to_group("enemy")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float):
	# Oyuncu yoksa veya düşman patlamaya başladıysa hareketi kes.
	if not is_instance_valid(player) or is_exploding:
		velocity = Vector2.ZERO
		return
		
	# Oyuncuya doğru koş
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	# YENİ MANTIK: Fiziksel olarak oyuncuya TEMA ETTİĞİ an patlar!
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Eğer çarptığımız şey "player" ise direkt patlat
		if collider != null and collider.is_in_group("player"):
			explode()

func explode():
	is_exploding = true # Artık hareket etmeyi bırakır
	
	# Çarpışmaları kapat ki patlarken sana takılıp titremesin
	$CollisionShape2D.set_deferred("disabled", true)
	
	# HASAR KISMI: Oyuncu patlama alanı (AoE) içindeyse hasar ver
	if is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= explosion_range:
			if player.has_method("take_damage"):
				player.take_damage(explosion_damage)
	
	if has_node("ExplosionSound"):
		$ExplosionSound.play()
	
	# GÖRSEL PATLAMA EFEKTİ (Şişme ve Kızarma)
	var tween = create_tween()
	modulate = Color(1.0, 0.3, 0.0) 
	tween.tween_property(self, "scale", Vector2(3.0, 3.0), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Efektin (0.3 saniye) bitmesini bekle
	await tween.finished
	
	queue_free() # Yok ol

func take_damage(amount: float):
	if has_node("HitSound"):
		$HitSound.play()
		
	if is_exploding: return 
	
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	if has_node("DeathSound"):
		$DeathSound.play()
	
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
