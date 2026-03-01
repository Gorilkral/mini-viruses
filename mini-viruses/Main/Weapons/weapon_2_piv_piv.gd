# SİLAH 2: OTOMATİK NİŞAN (PİVPİV) FIRLATICISI
# Belirli aralıklarla en yakın düşmanı bulur ve mermi atar.

extends Node2D

var bullet_scene = preload("res://Main/Weapons/auto_aim_bullet.tscn")

@onready var player = get_parent()
var timer := 0.0

func _process(delta: float):
	if player:
		var attack_interval = 1.0 / player.attack_speed
		timer += delta
		
		if timer >= attack_interval:
			shoot()
			timer = 0.0

func shoot():
	var closest_enemy = get_closest_enemy()
	if closest_enemy != null:
		# 1. Şarjörden bir mermi yarat
		var bullet = bullet_scene.instantiate()
		
		# 2. Merminin hasarını oyuncunun hasarına eşitle
		bullet.damage = player.attack_damage
		
		# 3. Mermiyi oyun dünyasına ekle (Player'ın içine değil, dış dünyaya)
		get_tree().root.add_child(bullet)
		
		# 4. Merminin çıkış noktasını oyuncunun tam ortası yap
		bullet.global_position = player.global_position
		
		# 5. Merminin ucunu (yönünü) en yakın düşmana çevir
		bullet.look_at(closest_enemy.global_position)

# EN YAKIN DÜŞMANI BULAN RADAR SİSTEMİ
func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest = null
	var min_dist = INF

	# --- GİRİNTİLERİ DÜZELTTİĞİMİZ KISIM BURASI ---
	var max_range = 350.0 * player.area_of_effect

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		
		# Düşman menzilin içindeyse ve şu ana kadar bulduğumuzdan daha yakınsa
		if dist < max_range and dist < min_dist:
			min_dist = dist
			closest = enemy
			
	return closest
