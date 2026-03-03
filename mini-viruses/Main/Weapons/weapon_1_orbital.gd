# SILAH 1: YÖRÜNGE PERVANESI (ORBITAL)
# Oyuncunun etrafında dönerek temas ettiği virüsleri anında yok eder.

extends Area2D

@onready var player = get_parent()

# 1. DÜĞÜMLERİ KODA BAĞLIYORUZ
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# 2. MUZUN ORİJİNAL BOYUT VE POZİSYONLARINI KAYDEDİYORUZ
@onready var base_sprite_scale = $Sprite2D.scale
@onready var base_sprite_pos = $Sprite2D.position

@onready var base_collision_scale = $CollisionShape2D.scale
@onready var base_collision_pos = $CollisionShape2D.position


# Taban dönme hızı
var base_rotation_speed := 4.0

func _ready():
	# SİNYAL: Muz fiziksel olarak bir bedene (düşmana) çarptığı AN "on_hit" fonksiyonunu tetikle
	body_entered.connect(on_hit)

func _process(delta: float) -> void:
	if player:
		# Oyuncuyu takip et
		global_position = player.global_position
		
		# Dönme hızını attack_speed ile çarpıyoruz (Hız aldıkça muzlar daha hızlı dönecek!)
		rotation += (base_rotation_speed * player.attack_speed) * delta
		
		# Büyüklüğü ayarla
		var weapon = float(player.weapon)
		
		
		if is_instance_valid(sprite):
			if sprite.scale.x < 1.2:
				# SADECE X EKSENİNİ BÜYÜT (Y ekseni sabit kalır, muz kalınlaşmaz)
				sprite.scale.x = base_sprite_scale.x * weapon
				
				# MUZUN SADECE SAĞA UZAMASI İÇİN POZİSYON HESAPLAMASI:
				# Objenin genişliğinin yarısı kadar bir kaydırma uyguluyoruz
				var orijinal_genislik = sprite.texture.get_width() * base_sprite_scale.x
				var kaydirma_miktari = (orijinal_genislik * (weapon - 1.0)) / 2.0
				
				# Pozisyonu sağa (+x) kaydır
				sprite.position.x = base_sprite_pos.x + kaydirma_miktari
			
		if is_instance_valid(collision):
			if sprite.scale.x < 1.2:
				# Çarpışma alanı için de sadece X eksenini büyüt
				collision.scale.x = base_collision_scale.x * weapon
				
				# Senin SegmentShape2D alanının sol ucu (A noktası) X=-104 koordinatında.
				# Sol ucun oyuncuda sabit kalması için o nokta baz alınarak sağa itilmeli.
				var carpisma_kaydirma = (104.0 * base_collision_scale.x) * (weapon - 1.0)
				collision.position.x = base_collision_pos.x + carpisma_kaydirma

# MUZ BİR ŞEYE ÇARPTIĞINDA ANINDA ÇALIŞAN FONKSİYON
func on_hit(body):
	# Çarptığı şey enemy grubundaysa ve hasar alma fonksiyonu varsa
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			# 999 çarpanıyla tokadı bas!
			body.take_damage(player.attack_damage)
