# DÜŞMAN 5: Menzilli Asit Kusan Virüs
extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: float = 15.0
@export var attack_range: float = 250.0 # Oyuncuya ne kadar uzaktan ateş edeceği (Biraz artırdım)
@export var fire_rate: float = 2.0
@export var min_xp_drop: int = 5
@export var max_xp_drop: int = 12

@export var projectile_scene: PackedScene # Inspector'dan mermiyi atayacağımız yer

var current_health: float
var player: Node2D
var fire_cooldown = 0.5

func _ready():
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
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if is_instance_valid(player) and player.has_method("add_xp"):
		player.add_xp(xp_drop)
	queue_free()
