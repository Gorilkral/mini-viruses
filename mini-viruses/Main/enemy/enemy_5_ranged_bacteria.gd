# DÜŞMAN 5: Menzilli Asit Kusan Virüs
extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: float = 15.0
@export var attack_range: float = 500.0 # Oyuncuya ne kadar uzaktan ateş edeceği (Biraz artırdım)
@export var fire_rate: float = 2.5
@export var min_xp_drop: int = 5
@export var max_xp_drop: int = 12

@export var projectile_scene: PackedScene # Inspector'dan mermiyi atayacağımız yer

var current_health: float
var player: Node2D
var fire_cooldown = 0.5

var is_dead: bool = false

func _ready():
	add_to_group("enemy")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	# ÇÖKME KORUMASI: Oyuncu öldüyse veya silindiyse hata verme, sadece dur!
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
		
	var distance = global_position.distance_to(player.global_position)
	
	# Mesafe koruma (Çok uzaktaysa yaklaş, yakındaysa dur)
	if distance > attack_range:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO # Menzile girince dur ve nişan al
		
	# Ateş etme süresi sayacı
	fire_cooldown -= delta
	if fire_cooldown <= 0.0 and distance <= attack_range:
		shoot()
		fire_cooldown = fire_rate

func shoot():
	if projectile_scene != null:
		var bullet = projectile_scene.instantiate()
		bullet.global_position = global_position
		
		# ÇÖKME KORUMASI 2: Oyuncu hayattaysa ona doğru mermi at
		if is_instance_valid(player):
			var direction = global_position.direction_to(player.global_position)
			
			# Mermiye yönünü ver (Merminin içindeki değişkene ulaşıyoruz)
			if "direction" in bullet:
				bullet.direction = direction
				
		# Mermiyi Ana Sahneye (En üste) ekle. (Parent'a eklersek mermi düşmanla beraber kayar)
		get_tree().root.call_deferred("add_child", bullet)

func take_damage(amount: float):
	if has_node("HitSound"):
		$HitSound.play()
		
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
