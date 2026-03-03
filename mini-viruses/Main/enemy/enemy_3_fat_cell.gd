# DÜŞMAN 3: Şişman Hücre (Tank Düşman)
# Görevi: Çok yavaş hareket eder ama yüksek canı ve hasarı vardır. Alanı daraltır.
# İstatistikleri: Çok yüksek can, çok yavaş hız, yüksek XP.

extends CharacterBody2D

@export var speed: float = 35.0
@export var max_health: float =  150.0
@export var min_xp_drop: int = 5
@export var max_xp_drop: int = 10
@export var attack_damage: float = 20.0 # Yavaş ama sağlam vurur

var current_health : float
var player: Node2D
var attack_cooldown: float = 0.0

var is_dead: bool = false

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
	if has_node("HitSound"):
		$HitSound.play()
		
	current_health -= damage_amount
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
