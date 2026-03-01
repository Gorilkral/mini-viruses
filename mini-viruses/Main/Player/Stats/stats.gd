extends CanvasLayer

@onready var stats_label = %StatsLabel
@onready var health_bar = %HealthBar
@onready var health_text = %HealthText
@onready var damage_bar = %DamageBar

var player: Node2D
var previous_health: float = 100
var damage_tween: Tween

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	# Oyun başladığında barları eşitliyoruz ki başta saçma durmasın
	if player:
		previous_health = player.current_health
		health_bar.value = player.current_health
		damage_bar.value = player.current_health

func _process(delta: float) -> void:
	if player:
		var current = player.current_health
		
		# Her iki barın da maksimum canını güncelliyoruz (Level atlayınca senkronize kalsınlar)
		health_bar.max_value = player.max_health
		damage_bar.max_value = player.max_health
		
		# Ana can barı animasyonsuz, her zaman güncel canı gösterir
		health_bar.value = current
		
		# EĞER HASAR YEDİYSEK (Canımız bir önceki kareden daha düşükse)
		if current < previous_health:
			
			# Eğer halihazırda çalışan bir animasyon varsa onu iptal et (titremeyi önler)
			if damage_tween:
				damage_tween.kill()
				
			# Arkadaki kırmızı bar için yeni bir animasyon başlat
			damage_tween = get_tree().create_tween()
			damage_tween.tween_interval(0.4) # 0.4 saniye bekle (Kırmızı alan havada kalır)
			# Ardından 0.3 saniye içinde kırmızı barı güncel cana doğru kaydır
			damage_tween.tween_property(damage_bar, "value", current, 0.3).set_trans(Tween.TRANS_SINE)
			
		# EĞER CANIMIZ ARTTIYSA (İyileşme veya Max Can yükselmesi)
		elif current > previous_health:
			damage_bar.value = current # İyileşirken arkadaki bar animasyonsuz anında dolsun
			
		# Bir sonraki karede karşılaştırmak için güncel canı hafızaya al
		previous_health = current
		
		# --- YAZI GÜNCELLEMELERİ ---
		health_text.text = str(int(round(player.current_health))) + " / " + str(round(player.max_health))
		
		var text_to_show = "[ Stats ]\n"
		text_to_show += "Damage: " + str(int(round(player.attack_damage))) + "\n"
		text_to_show += "Speed: " + str(int(round(player.speed))) + "\n"
		text_to_show += "AtkSpd: " + str(int(round(player.attack_speed))) + "\n"
		text_to_show += "AoE: " + str(int(round(player.area_of_effect)))
		
		stats_label.text = text_to_show
