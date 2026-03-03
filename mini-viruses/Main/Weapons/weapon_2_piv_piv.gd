extends Node2D

var bullet_scene = preload("res://Main/Weapons/auto_aim_bullet.tscn")

@onready var player = get_parent()
var timer := 0.0
var is_shooting := false # YENİ: Çakışmayı önlemek için kilit değişkeni

func _process(delta: float):
	# Eğer oyuncu varsa VE o an ateş etme döngüsünde değilsek çalış
	if player and not is_shooting:
		var attack_interval = 1.0 / player.attack_speed
		timer += delta
		
		if timer >= attack_interval:
			# 1. ÖNEMLİ: Zamanlayıcıyı hemen sıfırla ki bir sonraki karede tekrar girmesin
			timer = 0.0
			# 2. Ateş etme döngüsünü başlat
			fire_sequence()

# Ardışık ateş etme mantığını ayrı bir fonksiyona aldık
func fire_sequence():
	is_shooting = true # Kilidi kapat
	
	var projectile_to_throw = clamp(int(player.weapon), 1, 8)
	var attack_interval = 1.0 / player.attack_speed
	# Mermiler arasındaki gecikme süresi
	var delay = attack_interval / (projectile_to_throw + 1)
	
	for i in range(projectile_to_throw):
		shoot()
		# Eğer birden fazla mermi atacaksak araya bekleme koy
		if projectile_to_throw > 1:
			await get_tree().create_timer(delay).timeout
	
	is_shooting = false # Tüm mermiler atıldıktan sonra kilidi aç

func shoot():
	var closest_enemy = get_closest_enemy()
	if closest_enemy != null:
		var bullet = bullet_scene.instantiate()
		bullet.damage = player.attack_damage
		get_tree().root.add_child(bullet)
		bullet.global_position = player.global_position
		bullet.look_at(closest_enemy.global_position)

func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest = null
	var min_dist = INF
	var max_range = clamp(int(player.weapon * 200) ,200 ,2000)

	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < max_range and dist < min_dist:
				min_dist = dist
				closest = enemy
			
	return closest
