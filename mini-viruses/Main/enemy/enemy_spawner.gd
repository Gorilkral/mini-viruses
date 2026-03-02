extends Node2D

@export var enemy_scenes: Array[PackedScene]
@export var spawn_radius: float = 700.0 
@export var spawn_rate: float = 1.5

var previous_level = 1

# ---------------------------------------------------------
# 🎯 HER DÜŞMANIN ÇIKMA İHTİMALİ (Ağırlık Sistemi)
# Bu liste Inspector'daki enemy_scenes sırasıyla birebir aynı olmalı!
# Rakamlar toplam 100 olmak zorunda değil, birbiriyle oranlanır.
# ---------------------------------------------------------
var enemy_weights: Array[float] = [
	40.0, # 1. Düşman (Temel Bakteri) - Sürünün ana kaynağı, en çok bu çıkar
	10.0, # 2. Düşman (Hızlı Virüs) - Ara sıra arkadan koşanlar
	10.0,  # 3. Düşman (Şişman Hücre) - Nadir çıkan tanklar
	10.0, # 4. Düşman (Mitoz) - Ortalama sıklıkta
	25.0,  # 5. Düşman (Menzilli) - Gıcık eden nadir atıcılar
	5.0   # 6. Düşman (Kamikaze) - Çok nadir ama çok tehlikeli!
]

var spawn_timer: float = 0.0
var player: Node2D

func _ready():
	# Oyuncuyu daha güvenli bir şekilde grupla buluyoruz
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float):
	# Çökme koruması: Oyuncu ölürse veya sahneden silinirse spawn yapmayı durdur
	if not is_instance_valid(player):
		return

	spawn_timer -= delta

	if spawn_timer <= 0.0:
		spawn_enemy()
		spawn_timer = spawn_rate
		
	if is_instance_valid(player):
		if player.level > previous_level:
			var spawn_boost = randf_range(0.001, 0.005)
			spawn_rate -= spawn_rate * spawn_boost
			previous_level = player.level

func spawn_enemy():
	# Güvenlik: Sahneler boşsa veya ağırlık listemiz sahne sayısıyla uyuşmuyorsa iptal et
	if enemy_scenes.is_empty() or enemy_scenes.size() > enemy_weights.size():
		return

	# --- AĞIRLIKLI RASTGELE SEÇİM ALGORİTMASI ---
	var total_weight = 0.0
	for weight in enemy_weights:
		total_weight += weight

	var random_value = randf_range(0.0, total_weight)
	var current_weight = 0.0
	var selected_index = 0

	# Çekiliş yapıyoruz: Rastgele sayı hangi düşmanın dilimine düştüyse onu seç
	for i in range(enemy_weights.size()):
		current_weight += enemy_weights[i]
		if random_value <= current_weight:
			selected_index = i
			break
	# ---------------------------------------------

	var selected_scene = enemy_scenes[selected_index]

	if selected_scene != null:
		var enemy = selected_scene.instantiate() 
		
		# ==========================================================
		# 🚀 YENİ: DÜŞMANLARI OYUNCUNUN SEVİYESİNE GÖRE GÜÇLENDİRME
		# ==========================================================
		if is_instance_valid(player) and player.level > 1:
			var level_farki = player.level - 1 # 1. seviyede bonus yok, 2. seviyede 1 katı, 3'te 2 katı...
			
			# CAN ARTIŞI: Her level için %5 ile %15 arası rastgele bir artış
			if "max_health" in enemy:
				var health_boost = randf_range(0.001, 0.02) * level_farki
				enemy.max_health += enemy.max_health * health_boost
				
			# HASAR ARTIŞI: Her level için %5 ile %10 arası rastgele bir artış
			if "attack_damage" in enemy:
				var damage_boost = randf_range(0.001, 0.02) * level_farki
				enemy.attack_damage += enemy.attack_damage * damage_boost
				
			# HIZ ARTIŞI: Hız çok tehlikeli bir stattır, o yüzden daha az (%2 ile %5 arası) artsın
			if "speed" in enemy:
				var speed_boost = randf_range(0.001, 0.003) * level_farki
				enemy.speed += enemy.speed * speed_boost
				
			# İSTEĞE BAĞLI: Düşmanlar güçlendikçe daha çok XP versin
			if "min_xp_drop" in enemy and "max_xp_drop" in enemy:
				var xp_boost = randf_range(0.2, 0.4) * level_farki
				enemy.min_xp_drop += int(enemy.min_xp_drop * xp_boost)
				enemy.max_xp_drop += int(enemy.max_xp_drop * xp_boost)
		# ==========================================================
		
		var random_angle = randf_range(0, TAU)
		var direction_vector = Vector2.RIGHT.rotated(random_angle)
		var spawn_pos = player.global_position + (direction_vector * spawn_radius)

		enemy.global_position = spawn_pos
		get_parent().call_deferred("add_child", enemy)
		
		if has_node("SpawnSound"):
			$SpawnSound.play()
