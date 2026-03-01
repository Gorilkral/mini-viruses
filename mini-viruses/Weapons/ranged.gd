extends Node2D

var projectile_scene = preload("res://Weapons/Bullet.tscn")
@onready var shoot_timer = $ShootTimer
@onready var player = get_parent()

func _ready():
	_update_stats()

func _update_stats():
	# Player'daki attack_speed'e göre mermi sıklığını ayarla
	shoot_timer.wait_time = 1.0 / player.attack_speed

func _on_shoot_timer_timeout():
	_update_stats() # Statlar değişmiş olabilir, güncelle
	shoot_enemy()

func shoot_enemy():
	# 🎯 1. En yakın düşmanı bul
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() <= 0: return
	
	var closest_enemy = null
	var shortest_dist = INF
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < shortest_dist:
			shortest_dist = dist
			closest_enemy = enemy
			
	# 🚀 2. Mermiyi fırlat
	if closest_enemy:
		# projectile_count kadar mermi at (isteğe bağlı, şimdilik tekli)
		for i in range(int(player.projectile_count)):
			var p = projectile_scene.instantiate()
			# Mermiyi sahnenin en üstüne ekle (Player ile beraber kaymasın)
			get_tree().root.add_child(p) 
			p.global_position = global_position
			p.direction = global_position.direction_to(closest_enemy.global_position)
			p.damage = player.attack_damage
