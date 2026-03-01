extends CanvasLayer

@onready var stats_label = %StatsLabel
@onready var health_bar = %HealthBar
@onready var health_text = %HealthText
@onready var damage_bar = %DamageBar

# YENİ: XP Barımızı ve XP Yazımızı (Label) koda bağladık
@onready var xp_bar = %XpBar 
@onready var xp_text = %XpText 

var player: Node2D
var previous_health: float = 100
var damage_tween: Tween

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		previous_health = player.current_health
		health_bar.value = player.current_health
		damage_bar.value = player.current_health
		
		# Oyun başlarken XP Barının başlangıç ayarları
		if xp_bar:
			xp_bar.value = player.xp
			xp_bar.max_value = player.xp_required

func _process(delta: float) -> void:
	if player:
		var current = player.current_health
		
		# Can barlarının sınırlarını güncelle
		health_bar.max_value = player.max_health
		damage_bar.max_value = player.max_health
		health_bar.value = current
		
		# EĞER HASAR YEDİYSEK
		if current < previous_health:
			if damage_tween:
				damage_tween.kill()
				
			damage_tween = get_tree().create_tween()
			damage_tween.tween_interval(0.4) 
			damage_tween.tween_property(damage_bar, "value", current, 0.3).set_trans(Tween.TRANS_SINE)
			
		# EĞER CANIMIZ ARTTIYSA
		elif current > previous_health:
			damage_bar.value = current 
			
		previous_health = current
		
		# --- YENİ: XP BARI VE YAZISI GÜNCELLEMESİ ---
		if xp_bar:
			xp_bar.max_value = player.xp_required 
			xp_bar.value = lerp(xp_bar.value, float(player.xp), 10.0 * delta)
			
		if xp_text: # EĞER EKRANDA BİR YAZI (LABEL) VARSA ONU DA GÜNCELLE
			xp_text.text = " LEVEL " + str(int(player.level)) + "     XP " + str(int(player.xp)) + " / " + str(int(player.xp_required))
		
		# --- YAZI GÜNCELLEMELERİ ---
		health_text.text = str(int(round(player.current_health))) + " / " + str(round(player.max_health))
		
		var text_to_show = "[ Stats ]\n"
		text_to_show += "Damage: " + str(int(round(player.attack_damage))) + "\n"
		text_to_show += "Speed: " + str(int(round(player.speed))) + "\n"
		text_to_show += "AtkSpd: " + str(int(player.attack_speed * 100))
		
		stats_label.text = text_to_show
